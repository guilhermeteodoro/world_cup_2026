class AddStateToUserStickersAndBackfill < ActiveRecord::Migration[8.1]
  def up
    add_column :user_stickers, :state, :string

    # Remove the old unique index first — we're about to insert duplicate rows
    remove_index :user_stickers, column: [ :user_id, :sticker_id ], unique: true

    # Backfill: all existing rows become glued
    execute "UPDATE user_stickers SET state = 'glued'"

    # Expand copies into individual duplicate rows using recursive CTE
    # This creates N rows with state 'duplicate' for each row with copies > 0
    execute <<~SQL
      WITH RECURSIVE copy_expansion(user_id, sticker_id, remaining, created_at, updated_at, deleted_at) AS (
        SELECT user_id, sticker_id, copies, created_at, updated_at, deleted_at
        FROM user_stickers
        WHERE copies > 0
        UNION ALL
        SELECT user_id, sticker_id, remaining - 1, created_at, updated_at, deleted_at
        FROM copy_expansion
        WHERE remaining > 1
      )
      INSERT INTO user_stickers (user_id, sticker_id, state, created_at, updated_at, deleted_at)
      SELECT user_id, sticker_id, 'duplicate', created_at, updated_at, deleted_at
      FROM copy_expansion
    SQL

    remove_column :user_stickers, :copies

    # Add partial unique index: only one glued per user+sticker among non-deleted rows
    add_index :user_stickers, [ :user_id, :sticker_id ],
      unique: true,
      where: "state = 'glued' AND deleted_at IS NULL",
      name: "index_user_stickers_unique_glued"

    add_index :user_stickers, :state
  end

  def down
    remove_index :user_stickers, name: "index_user_stickers_unique_glued"
    remove_index :user_stickers, :state

    # Restore the old unique index
    # First, remove duplicate rows
    execute "DELETE FROM user_stickers WHERE state != 'glued'"

    add_index :user_stickers, [ :user_id, :sticker_id ], unique: true

    # Restore copies column
    add_column :user_stickers, :copies, :integer, default: 0, null: false

    remove_column :user_stickers, :state
  end
end
