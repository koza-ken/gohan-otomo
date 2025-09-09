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

  describe "画像バリデーション" do
    let(:user) { create(:user) }
    let(:post) { build(:post, user: user) }

    describe "画像形式チェック" do
      it "JPEG形式の画像は有効" do
        post.image.attach(
          io: StringIO.new("fake jpeg data"),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(post.valid?).to be true
      end

      it "PNG形式の画像は有効" do
        post.image.attach(
          io: StringIO.new("fake png data"),
          filename: 'test.png',
          content_type: 'image/png'
        )
        expect(post.valid?).to be true
      end

      it "WebP形式の画像は有効" do
        post.image.attach(
          io: StringIO.new("fake webp data"),
          filename: 'test.webp',
          content_type: 'image/webp'
        )
        expect(post.valid?).to be true
      end

      it "GIF形式の画像は有効" do
        post.image.attach(
          io: StringIO.new("fake gif data"),
          filename: 'test.gif',
          content_type: 'image/gif'
        )
        expect(post.valid?).to be true
      end

      it "PDF形式のファイルは無効" do
        post.image.attach(
          io: StringIO.new("fake pdf data"),
          filename: 'document.pdf',
          content_type: 'application/pdf'
        )
        expect(post.valid?).to be false
        expect(post.errors[:image]).to include('画像はJPEG、PNG、WebP、GIF形式でアップロードしてください')
      end

      it "テキストファイルは無効" do
        post.image.attach(
          io: StringIO.new("fake text data"),
          filename: 'document.txt',
          content_type: 'text/plain'
        )
        expect(post.valid?).to be false
        expect(post.errors[:image]).to include('画像はJPEG、PNG、WebP、GIF形式でアップロードしてください')
      end
    end

    describe "画像サイズチェック" do
      it "10MB以下の画像は有効" do
        post.image.attach(
          io: StringIO.new("a" * (5 * 1024 * 1024)), # 5MB
          filename: 'large.jpg',
          content_type: 'image/jpeg'
        )
        expect(post.valid?).to be true
      end

      it "10MB超の画像は無効" do
        post.image.attach(
          io: StringIO.new("a" * (15 * 1024 * 1024)), # 15MB
          filename: 'too_large.jpg',
          content_type: 'image/jpeg'
        )
        expect(post.valid?).to be false
        expect(post.errors[:image]).to include('画像サイズは10MB以下でアップロードしてください')
      end
    end

    it "画像が添付されていない場合は有効" do
      expect(post.valid?).to be true
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

  # 検索機能のテスト
  describe ".search_by_keyword" do
    let(:user) { create(:user) }
    let!(:post1) { create(:post, title: "明太子", description: "福岡の名産品", user: user) }
    let!(:post2) { create(:post, title: "いくら", description: "北海道の海鮮", user: user) }
    let!(:post3) { create(:post, title: "のり佃煮", description: "甘辛い明太子味", user: user) }

    context "キーワードが指定されている場合" do
      it "titleに一致する投稿を返す" do
        results = Post.search_by_keyword("明太子")
        expect(results).to include(post1, post3)
        expect(results).not_to include(post2)
      end

      it "descriptionに一致する投稿を返す" do
        results = Post.search_by_keyword("北海道")
        expect(results).to include(post2)
        expect(results).not_to include(post1, post3)
      end

      it "部分一致で検索できる" do
        results = Post.search_by_keyword("太子")
        expect(results).to include(post1, post3)
        expect(results).not_to include(post2)
      end

      it "英字の大文字小文字を区別しない" do
        post_en = create(:post, title: "Mentaiko", description: "Fukuoka specialty", user: user)
        results = Post.search_by_keyword("mentaiko")
        expect(results).to include(post_en)
      end

      it "該当する投稿がない場合は空の結果を返す" do
        results = Post.search_by_keyword("存在しないキーワード")
        expect(results).to be_empty
      end
    end

    context "キーワードが空の場合" do
      it "全ての投稿を返す" do
        results = Post.search_by_keyword("")
        expect(results).to include(post1, post2, post3)
      end

      it "nilの場合も全ての投稿を返す" do
        results = Post.search_by_keyword(nil)
        expect(results).to include(post1, post2, post3)
      end
    end
  end

  describe "いいね機能" do
    let(:user) { create(:user) }
    let(:user2) { create(:user, display_name: "ユーザー2", email: "user2@example.com") }
    let(:post_record) { create(:post, user: user) }

    describe "associations" do
      it "has many likes with dependent destroy" do
        user = create(:user)
        post_record = create(:post)
        like1 = create(:like, user: user, post: post_record)
        like2 = create(:like, user: create(:user, display_name: "別のユーザー", email: "other@example.com"), post: post_record)
        
        expect(post_record.likes.count).to eq(2)
        expect(post_record.likes).to include(like1, like2)
        
        # dependent: destroyの確認
        expect { post_record.destroy }.to change { Like.count }.by(-2)
      end
    end

    describe "#likes_count" do
      it "いいね数を正確に返す" do
        expect(post_record.likes_count).to eq(0)
        
        create(:like, user: user, post: post_record)
        expect(post_record.likes_count).to eq(1)
        
        create(:like, user: user2, post: post_record)
        expect(post_record.likes_count).to eq(2)
      end
    end

    describe "#liked_by?" do
      it "ユーザーがいいねしている場合はtrueを返す" do
        create(:like, user: user, post: post_record)
        expect(post_record.liked_by?(user)).to be true
      end

      it "ユーザーがいいねしていない場合はfalseを返す" do
        expect(post_record.liked_by?(user)).to be false
      end

      it "ユーザーがnilの場合はfalseを返す" do
        expect(post_record.liked_by?(nil)).to be false
      end

      it "異なるユーザーのいいね状態は影響しない" do
        create(:like, user: user2, post: post_record)
        expect(post_record.liked_by?(user)).to be false
        expect(post_record.liked_by?(user2)).to be true
      end
    end

    describe "dependency" do
      it "投稿を削除するとそのいいねも削除される" do
        create(:like, user: user, post: post_record)
        create(:like, user: user2, post: post_record)
        
        expect { post_record.destroy }.to change { Like.count }.by(-2)
      end
    end
  end
end
