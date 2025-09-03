require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    describe "content" do
      it "必須項目である" do
        comment = Comment.new(content: nil, user: user, post: post)
        expect(comment.valid?).to be false
        expect(comment.errors[:content]).to include("can't be blank")
      end

      it "空文字の場合は無効" do
        comment = Comment.new(content: "", user: user, post: post)
        expect(comment.valid?).to be false
        expect(comment.errors[:content]).to include("can't be blank")
      end

      it "300文字以下の場合は有効" do
        comment = Comment.new(content: "a" * 300, user: user, post: post)
        expect(comment.valid?).to be true
      end

      it "301文字以上の場合は無効" do
        comment = Comment.new(content: "a" * 301, user: user, post: post)
        expect(comment.valid?).to be false
        expect(comment.errors[:content]).to include("is too long (maximum is 300 characters)")
      end
    end

    describe "関連" do
      it "userが必須である" do
        comment = Comment.new(content: "テストコメント", user: nil, post: post)
        expect(comment.valid?).to be false
        expect(comment.errors[:user]).to include("must exist")
      end

      it "postが必須である" do
        comment = Comment.new(content: "テストコメント", user: user, post: nil)
        expect(comment.valid?).to be false
        expect(comment.errors[:post]).to include("must exist")
      end
    end
  end
end
