class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false  # 商品名（必須）
      t.text :description, null: false  # おすすめポイント（必須）
      t.string :link  # 通販リンク（任意）
      t.string :image_url  # 外部画像URL（任意）

      t.timestamps
    end

    # ユーザー投稿の検索用
    add_index :posts, :user_id
    # 作成日時による並び替え用
    add_index :posts, :created_at
    # 商品名での検索用
    add_index :posts, :title
  end
end
