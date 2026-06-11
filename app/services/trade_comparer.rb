# frozen_string_literal: true

# Computes trade opportunities between two users.
# Returns a structured result with full diff and balanced suggestion.
class TradeComparer
  Result = Data.define(:a_gives_b, :b_gives_a, :balanced, :leftovers)
  BalancedTrade = Data.define(:shiny, :coke, :normal)
  TradePair = Data.define(:a_gives, :b_gives)
  Leftovers = Data.define(:a_has, :b_has)

  def initialize(user_a, user_b)
    @user_a = user_a
    @user_b = user_b
  end

  def call
    a_duplicates = duplicate_sticker_ids(@user_a)
    b_duplicates = duplicate_sticker_ids(@user_b)
    a_missing = missing_sticker_ids(@user_a)
    b_missing = missing_sticker_ids(@user_b)

    # Full diff: what each can give the other
    a_gives_b = a_duplicates & b_missing
    b_gives_a = b_duplicates & a_missing

    # Categorize
    a_by_cat = categorize(a_gives_b)
    b_by_cat = categorize(b_gives_a)

    # Build balanced trade + leftovers
    balanced = {}
    leftovers_a = {}
    leftovers_b = {}

    [ :shiny, :coke, :normal ].each do |cat|
      a_pool = a_by_cat[cat]
      b_pool = b_by_cat[cat]
      trade_count = [ a_pool.size, b_pool.size ].min

      balanced[cat] = TradePair.new(
        a_gives: a_pool.first(trade_count),
        b_gives: b_pool.first(trade_count)
      )
      leftovers_a[cat] = a_pool.drop(trade_count)
      leftovers_b[cat] = b_pool.drop(trade_count)
    end

    Result.new(
      a_gives_b: load_stickers(a_gives_b),
      b_gives_a: load_stickers(b_gives_a),
      balanced: BalancedTrade.new(
        shiny: TradePair.new(
          a_gives: load_stickers(balanced[:shiny].a_gives),
          b_gives: load_stickers(balanced[:shiny].b_gives)
        ),
        coke: TradePair.new(
          a_gives: load_stickers(balanced[:coke].a_gives),
          b_gives: load_stickers(balanced[:coke].b_gives)
        ),
        normal: TradePair.new(
          a_gives: load_stickers(balanced[:normal].a_gives),
          b_gives: load_stickers(balanced[:normal].b_gives)
        )
      ),
      leftovers: Leftovers.new(
        a_has: load_stickers(leftovers_a.values.flatten),
        b_has: load_stickers(leftovers_b.values.flatten)
      )
    )
  end

  private

  def duplicate_sticker_ids(user)
    user.user_stickers.duplicates.pluck(:sticker_id).to_set
  end

  def missing_sticker_ids(user)
    all_ids = Sticker.pluck(:id).to_set
    owned_ids = user.user_stickers.glued.pluck(:sticker_id).to_set
    all_ids - owned_ids
  end

  def categorize(sticker_ids)
    stickers = Sticker.where(id: sticker_ids.to_a).order(:position)
    result = { shiny: [], coke: [], normal: [] }
    stickers.each { |s| result[s.category.to_sym] << s.id }
    result
  end

  def load_stickers(ids)
    return [] if ids.empty?
    Sticker.includes(:country).where(id: ids).order(:position).to_a
  end
end
