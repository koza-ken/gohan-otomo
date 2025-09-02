class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.text :content, null: false  # 感想コメント（必須）

      t.timestamps
    end

    # 投稿に対するコメント一覧表示用
    add_index :comments, [:post_id, :created_at]
    # ユーザーのコメント履歴用
    add_index :comments, :user_id
  end
end
