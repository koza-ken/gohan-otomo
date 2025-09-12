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

  describe "カスタムメソッド" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, display_name: 'other_user', email: 'other@example.com') }
    let(:post_record) { create(:post, user: user) }
    let(:comment) { create(:comment, user: user, post: post_record) }

    describe "#deletable_by?" do
      context "コメント作成者の場合" do
        it "trueを返す" do
          expect(comment.deletable_by?(user)).to be true
        end
      end

      context "コメント作成者でない場合" do
        it "falseを返す" do
          expect(comment.deletable_by?(other_user)).to be false
        end
      end

      context "ユーザーがnilの場合" do
        it "falseを返す" do
          expect(comment.deletable_by?(nil)).to be false
        end
      end
    end

    describe "#time_ago_in_words_japanese" do
      context "30秒前に作成された場合" do
        before { allow(Time).to receive(:current).and_return(comment.created_at + 30.seconds) }

        it "秒前を返す" do
          expect(comment.time_ago_in_words_japanese).to eq('30秒前')
        end
      end

      context "5分前に作成された場合" do
        before { allow(Time).to receive(:current).and_return(comment.created_at + 5.minutes) }

        it "分前を返す" do
          expect(comment.time_ago_in_words_japanese).to eq('5分前')
        end
      end

      context "3時間前に作成された場合" do
        before { allow(Time).to receive(:current).and_return(comment.created_at + 3.hours) }

        it "時間前を返す" do
          expect(comment.time_ago_in_words_japanese).to eq('3時間前')
        end
      end

      context "5日前に作成された場合" do
        before { allow(Time).to receive(:current).and_return(comment.created_at + 5.days) }

        it "日前を返す" do
          expect(comment.time_ago_in_words_japanese).to eq('5日前')
        end
      end

      context "31日前に作成された場合" do
        before { allow(Time).to receive(:current).and_return(comment.created_at + 31.days) }

        it "日付形式を返す" do
          expected_date = comment.created_at.strftime("%Y年%m月%d日")
          expect(comment.time_ago_in_words_japanese).to eq(expected_date)
        end
      end
    end

    describe "#formatted_content" do
      context "単一行コンテンツの場合" do
        let(:comment) { create(:comment, content: 'これは一行のコメントです', user: user, post: post_record) }

        it "simple_formatでp要素に変換する" do
          expect(comment.formatted_content).to eq('<p>これは一行のコメントです</p>')
        end
      end

      context "改行を含むコンテンツの場合" do
        let(:comment) { create(:comment, content: "一行目\n二行目\n三行目", user: user, post: post_record) }

        it "改行を<br />タグに変換し、p要素で囲む" do
          expected = "<p>一行目\n<br />二行目\n<br />三行目</p>"
          expect(comment.formatted_content).to eq(expected)
        end
      end

      context "html_safeな文字列を返す" do
        let(:comment) { create(:comment, content: "一行目\n二行目", user: user, post: post_record) }

        it "html_safeな文字列を返す" do
          result = comment.formatted_content
          expect(result).to be_html_safe
        end
      end
    end
  end
end
