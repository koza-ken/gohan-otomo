require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "有効なファクトリを持つ" do
      expect(build(:user)).to be_valid
    end

    describe "display_name" do
      it "存在する必要がある" do
        user = build(:user, display_name: nil)
        expect(user).not_to be_valid
        expect(user.errors[:display_name]).to include("can't be blank")
      end

      it "20文字以下である必要がある" do
        user = build(:user, :with_long_display_name)
        expect(user).not_to be_valid
        expect(user.errors[:display_name]).to include("is too long (maximum is 20 characters)")
      end

      it "一意である必要がある" do
        create(:user, display_name: "テストユーザー")
        user = build(:user, display_name: "テストユーザー")
        expect(user).not_to be_valid
        expect(user.errors[:display_name]).to include("has already been taken")
      end

      it "大文字小文字を区別しない一意性チェック" do
        create(:user, display_name: "TestUser")
        user = build(:user, display_name: "testuser")
        expect(user).not_to be_valid
        expect(user.errors[:display_name]).to include("has already been taken")
      end
    end

    describe "email" do
      it "存在する必要がある" do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it "一意である必要がある" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("has already been taken")
      end

      it "有効な形式である必要がある" do
        user = build(:user, email: "invalid_email")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is invalid")
      end
    end

    describe "password" do
      it "6文字以上である必要がある" do
        user = build(:user, password: "12345", password_confirmation: "12345")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end
    end

    describe "favorite_foods" do
      it "200文字以下である必要がある" do
        user = build(:user, favorite_foods: "a" * 201)
        expect(user).not_to be_valid
        expect(user.errors[:favorite_foods]).to include("is too long (maximum is 200 characters)")
      end

      it "空白でも有効" do
        user = build(:user, favorite_foods: "")
        expect(user).to be_valid
      end

      it "nilでも有効" do
        user = build(:user, favorite_foods: nil)
        expect(user).to be_valid
      end
    end

    describe "disliked_foods" do
      it "200文字以下である必要がある" do
        user = build(:user, disliked_foods: "a" * 201)
        expect(user).not_to be_valid
        expect(user.errors[:disliked_foods]).to include("is too long (maximum is 200 characters)")
      end

      it "空白でも有効" do
        user = build(:user, disliked_foods: "")
        expect(user).to be_valid
      end

      it "nilでも有効" do
        user = build(:user, disliked_foods: nil)
        expect(user).to be_valid
      end
    end

    describe "profile_public" do
      it "デフォルトでtrueである" do
        user = build(:user)
        expect(user.profile_public).to be true
      end

      it "falseに設定できる" do
        user = build(:user, profile_public: false)
        expect(user.profile_public).to be false
      end
    end
  end

  describe "作成" do
    it "有効な属性でユーザーを作成できる" do
      expect {
        create(:user)
      }.to change(User, :count).by(1)
    end
  end

  describe "いいね機能" do
    let(:user) { create(:user) }
    let(:user2) { create(:user, display_name: "ユーザー2", email: "user2@example.com") }
    let(:post1) { create(:post, title: "投稿1") }
    let(:post2) { create(:post, title: "投稿2") }

    describe "associations" do
      it "has many likes with dependent destroy" do
        user = create(:user)
        post1 = create(:post)
        post2 = create(:post, title: "投稿2")
        like1 = create(:like, user: user, post: post1)
        like2 = create(:like, user: user, post: post2)
        
        expect(user.likes.count).to eq(2)
        expect(user.likes).to include(like1, like2)
        
        # dependent: destroyの確認
        expect { user.destroy }.to change { Like.count }.by(-2)
      end
      
      it "has many liked_posts through likes" do
        user = create(:user)
        post1 = create(:post, title: "投稿1")
        post2 = create(:post, title: "投稿2")
        create(:like, user: user, post: post1)
        create(:like, user: user, post: post2)
        
        expect(user.liked_posts.count).to eq(2)
        expect(user.liked_posts).to include(post1, post2)
        expect(user.liked_posts.first).to be_a(Post)
      end
    end

    describe "#liked_posts" do
      it "いいねした投稿を正しく取得する" do
        create(:like, user: user, post: post1)
        create(:like, user: user, post: post2)
        
        expect(user.liked_posts).to include(post1, post2)
        expect(user.liked_posts.count).to eq(2)
      end

      it "他のユーザーがいいねした投稿は含まれない" do
        create(:like, user: user, post: post1)
        create(:like, user: user2, post: post2)
        
        expect(user.liked_posts).to include(post1)
        expect(user.liked_posts).not_to include(post2)
      end

      it "いいねしていない場合は空を返す" do
        expect(user.liked_posts).to be_empty
      end
    end

    describe "#liked_posts_count" do
      it "いいねした投稿数を正確に返す" do
        expect(user.liked_posts_count).to eq(0)
        
        create(:like, user: user, post: post1)
        expect(user.liked_posts_count).to eq(1)
        
        create(:like, user: user, post: post2)
        expect(user.liked_posts_count).to eq(2)
      end
    end

    describe "#likes_count" do
      it "ユーザーが行ったいいね総数を返す" do
        expect(user.likes_count).to eq(0)
        
        create(:like, user: user, post: post1)
        expect(user.likes_count).to eq(1)
        
        create(:like, user: user, post: post2)
        expect(user.likes_count).to eq(2)
      end
    end

    describe "dependency" do
      it "ユーザーを削除するとそのいいねも削除される" do
        create(:like, user: user, post: post1)
        create(:like, user: user, post: post2)
        
        expect { user.destroy }.to change { Like.count }.by(-2)
      end

      it "ユーザーを削除してもいいねされた投稿は残る" do
        create(:like, user: user, post: post1)
        
        expect { user.destroy }.not_to change { Post.count }
        expect(post1.reload).to be_persisted
      end
    end
  end
end
