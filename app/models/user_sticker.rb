# frozen_string_literal: true

# == Schema Information
#
# Table name: user_stickers
#
#  id         :integer          not null, primary key
#  state      :string           not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sticker_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_stickers_on_sticker_id      (sticker_id)
#  index_user_stickers_on_state           (state)
#  index_user_stickers_on_user_id         (user_id)
#  index_user_stickers_unique_glued       (user_id,sticker_id) UNIQUE WHERE state = 'glued' AND deleted_at IS NULL
#
# Foreign Keys
#
#  sticker_id  (sticker_id => stickers.id)
#  user_id     (user_id => users.id)
#
class UserSticker < ApplicationRecord
  STATES = %w[glued duplicate to_be_glued incoming].freeze

  belongs_to :user
  belongs_to :sticker
  belongs_to :trade, optional: true

  validates :state, presence: true, inclusion: { in: STATES }
  validates :sticker_id, uniqueness: { scope: :user_id, conditions: -> { kept.where(state: :glued) } },
    if: -> { state == "glued" }

  scope :glued, -> { where(state: :glued) }
  scope :duplicates, -> { where(state: :duplicate) }
  scope :to_be_glued, -> { where(state: :to_be_glued) }
  scope :incoming, -> { where(state: :incoming) }
  scope :active, -> { kept.where(state: %w[glued duplicate to_be_glued incoming]) }
end
