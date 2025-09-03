require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }
    
    describe "title" do
      it "必須項目である" do
        post = Post.new(title: nil, description: "テスト", user: user)
        expect(post.valid?).to be false
        expect(post.errors[:title]).to include("can't be blank")
      end

      it "100文字以下の場合は有効" do
        post = Post.new(title: "a" * 100, description: "テスト", user: user)
        expect(post.valid?).to be true
      end

      it "101文字以上の場合は無効" do
        post = Post.new(title: "a" * 101, description: "テスト", user: user)
        expect(post.valid?).to be false
        expect(post.errors[:title]).to include("is too long (maximum is 100 characters)")
      end
    end

    describe "description" do
      it "必須項目である" do
        post = Post.new(title: "テスト商品", description: nil, user: user)
        expect(post.valid?).to be false
        expect(post.errors[:description]).to include("can't be blank")
      end

      it "200文字以下の場合は有効" do
        post = Post.new(title: "テスト商品", description: "a" * 200, user: user)
        expect(post.valid?).to be true
      end

      it "201文字以上の場合は無効" do
        post = Post.new(title: "テスト商品", description: "a" * 201, user: user)
        expect(post.valid?).to be false
        expect(post.errors[:description]).to include("is too long (maximum is 200 characters)")
      end
    end

    describe "link" do
      it "空の場合は有効" do
        post = Post.new(title: "テスト商品", description: "テスト", link: "", user: user)
        expect(post.valid?).to be true
      end

      it "正しいURL形式の場合は有効" do
        post = Post.new(title: "テスト商品", description: "テスト", link: "https://example.com", user: user)
        expect(post.valid?).to be true
      end

      it "httpのURL形式も有効" do
        post = Post.new(title: "テスト商品", description: "テスト", link: "http://example.com", user: user)
        expect(post.valid?).to be true
      end

      it "不正なURL形式の場合は無効" do
        post = Post.new(title: "テスト商品", description: "テスト", link: "invalid-url", user: user)
        expect(post.valid?).to be false
        expect(post.errors[:link]).to include("正しいURLを入力してください")
      end

      it "500文字以上の場合は無効" do
        long_url = "https://example.com/" + "a" * 500
        post = Post.new(title: "テスト商品", description: "テスト", link: long_url, user: user)
        expect(post.valid?).to be false
        expect(post.errors[:link]).to include("is too long (maximum is 500 characters)")
      end
    end

    describe "image_url" do
      it "空の場合は有効" do
        post = Post.new(title: "テスト商品", description: "テスト", image_url: "", user: user)
        expect(post.valid?).to be true
      end

      it "正しいURL形式の場合は有効" do
        post = Post.new(title: "テスト商品", description: "テスト", image_url: "https://example.com/image.jpg", user: user)
        expect(post.valid?).to be true
      end

      it "不正なURL形式の場合は無効" do
        post = Post.new(title: "テスト商品", description: "テスト", image_url: "not-a-url", user: user)
        expect(post.valid?).to be false
        expect(post.errors[:image_url]).to include("正しいURLを入力してください")
      end
    end
  end

  describe "アソシエーション" do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    it "userに属している" do
      expect(post.user).to eq(user)
    end

    it "複数のコメントを持てる" do
      comment1 = create(:comment, post: post, user: user)
      comment2 = create(:comment, post: post, user: user)
      
      expect(post.comments).to include(comment1, comment2)
      expect(post.comments.count).to eq(2)
    end

    it "投稿が削除されるとコメントも削除される" do
      comment = create(:comment, post: post, user: user)
      comment_id = comment.id
      
      post.destroy
      
      expect(Comment.find_by(id: comment_id)).to be_nil
    end
  end

  describe "メソッド" do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    describe "#comments_count" do
      it "コメント数を正しく返す" do
        expect(post.comments_count).to eq(0)
        
        create(:comment, post: post, user: user)
        expect(post.comments_count).to eq(1)
        
        create(:comment, post: post, user: user)
        expect(post.comments_count).to eq(2)
      end
    end
  end
end
