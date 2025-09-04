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

  describe "Active Storage" do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }
    
    describe "画像添付機能" do
      it "画像を添付できる" do
        expect(post.image.attached?).to be false
        
        # Rails 7推奨のfixture_file_uploadを使用
        file = fixture_file_upload('test_image.jpg', 'image/jpeg')
        post.image.attach(file)
        
        expect(post.image.attached?).to be true
        expect(post.image.filename.to_s).to eq('test_image.jpg')
        # fixture_file_uploadではcontent_typeが自動判定されるため、柔軟に対応
        expect(post.image.content_type).to match(/^image\/.*$/)
      end

      it "画像を削除できる" do
        # 画像を添付
        file = fixture_file_upload('test_image.jpg', 'image/jpeg')
        post.image.attach(file)
        expect(post.image.attached?).to be true
        
        # 画像を削除
        post.image.purge
        expect(post.image.attached?).to be false
      end
    end

    describe "画像variant生成" do
      before do
        file = fixture_file_upload('test_image.jpg', 'image/jpeg')
        post.image.attach(file)
      end

      it "thumbnail_imageでサムネイル画像を生成できる" do
        thumbnail = post.thumbnail_image
        expect(thumbnail).to be_present
        expect(thumbnail).to be_a(ActiveStorage::VariantWithRecord)
      end

      it "medium_imageで中サイズ画像を生成できる" do
        medium = post.medium_image
        expect(medium).to be_present
        expect(medium).to be_a(ActiveStorage::VariantWithRecord)
      end

      it "画像が添付されていない場合はnilを返す" do
        post_without_image = create(:post, user: user)
        expect(post_without_image.thumbnail_image).to be_nil
        expect(post_without_image.medium_image).to be_nil
      end
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

    describe "#safe_link" do
      it "有効なHTTPSリンクを返す" do
        post = create(:post, link: "https://example.com")
        expect(post.safe_link).to eq("https://example.com")
      end

      it "有効なHTTPリンクを返す" do  
        post = create(:post, link: "http://example.com")
        expect(post.safe_link).to eq("http://example.com")
      end

      it "javascriptスキームの場合nilを返す" do
        post = build(:post, link: "javascript:alert('xss')")
        expect(post.safe_link).to be_nil
      end

      it "dataスキームの場合nilを返す" do
        post = build(:post, link: "data:text/html,<script>alert('xss')</script>")
        expect(post.safe_link).to be_nil
      end

      it "不正なURIの場合nilを返す" do
        post = build(:post, link: "invalid-uri")
        expect(post.safe_link).to be_nil
      end

      it "linkがnilの場合nilを返す" do
        post = create(:post, link: nil)
        expect(post.safe_link).to be_nil
      end

      it "空文字の場合nilを返す" do
        post = create(:post, link: "")  
        expect(post.safe_link).to be_nil
      end
    end

    describe "#display_image" do
      let(:post) { create(:post, user: user) }

      context "Active Storage画像が添付されている場合" do
        before do
          file = fixture_file_upload('test_image.jpg', 'image/jpeg')
          post.image.attach(file)
        end

        it "thumbnailサイズの場合はthumbnail_imageを返す" do
          result = post.display_image(:thumbnail)
          expect(result).to be_a(ActiveStorage::VariantWithRecord)
          # VariantWithRecordの比較は内部のvariation_digestで行う
          expect(result.variation.digest).to eq(post.thumbnail_image.variation.digest)
        end

        it "mediumサイズの場合はmedium_imageを返す" do
          result = post.display_image(:medium)
          expect(result).to be_a(ActiveStorage::VariantWithRecord)
          expect(result.variation.digest).to eq(post.medium_image.variation.digest)
        end

        it "largeサイズの場合もmedium_imageを返す" do
          result = post.display_image(:large)
          expect(result).to be_a(ActiveStorage::VariantWithRecord)
          expect(result.variation.digest).to eq(post.medium_image.variation.digest)
        end
      end

      context "Active Storage画像がなく、image_urlがある場合" do
        let(:post) { create(:post, :with_image, user: user) }

        it "image_urlを返す" do
          result = post.display_image(:thumbnail)
          expect(result).to eq(post.image_url)
        end

        it "mediumサイズでもimage_urlを返す" do
          result = post.display_image(:medium)
          expect(result).to eq(post.image_url)
        end
      end

      context "Active Storage画像もimage_urlもない場合" do
        it "nilを返す" do
          result = post.display_image(:thumbnail)
          expect(result).to be_nil
        end
      end

      context "デフォルトサイズの場合" do
        before do
          file = fixture_file_upload('test_image.jpg', 'image/jpeg')
          post.image.attach(file)
        end

        it "引数なしの場合はmediumサイズを返す" do
          result = post.display_image
          expect(result.variation.digest).to eq(post.medium_image.variation.digest)
        end
      end
    end

    describe "#has_image?" do
      it "Active Storage画像が添付されている場合はtrueを返す" do
        file = fixture_file_upload('test_image.jpg', 'image/jpeg')
        post.image.attach(file)
        expect(post.has_image?).to be true
      end

      it "image_urlがある場合はtrueを返す" do
        post = create(:post, :with_image, user: user)
        expect(post.has_image?).to be true
      end

      it "Active Storage画像とimage_url両方がある場合はtrueを返す" do
        post = create(:post, :with_image, user: user)
        file = fixture_file_upload('test_image.jpg', 'image/jpeg')
        post.image.attach(file)
        expect(post.has_image?).to be true
      end

      it "どちらもない場合はfalseを返す" do
        expect(post.has_image?).to be false
      end
    end
  end
end
