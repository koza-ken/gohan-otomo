require 'rails_helper'

RSpec.describe 'Comments', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, display_name: 'other_user', email: 'other@example.com') }
  let(:post_record) { create(:post, user: user) }

  describe 'コメント投稿機能' do
    context 'ログイン済みユーザーの場合' do
      before do
        sign_in user
        visit post_path(post_record)
      end

      it 'コメントフォームが表示される' do
        expect(page).to have_css('#comment_form')
        expect(page).to have_field('comment[content]')
        expect(page).to have_button('コメント投稿')
      end

      it 'コメント投稿者の名前が表示される' do
        within '#comment_form' do
          expect(page).to have_text(user.display_name)
        end
      end

      it '文字数カウンターが表示される' do
        expect(page).to have_css('#comment_counter')
        expect(page).to have_text('0 / 300 文字')
      end

      describe 'コメント投稿' do
        it '有効なコメントを投稿できる', js: true do
          comment_text = 'とても美味しそうですね！'
          
          within '#comment_form' do
            fill_in 'comment[content]', with: comment_text
            click_button 'コメント投稿'
          end

          # Ajax処理を待機
          sleep 1

          # コメントがリストに追加されることを確認
          within '#comments_list' do
            expect(page).to have_text(comment_text)
            expect(page).to have_text(user.display_name)
          end

          # フォームがリセットされることを確認
          expect(find_field('comment[content]').value).to be_empty
        end

        it '空のコメントは投稿できない', js: true do
          within '#comment_form' do
            fill_in 'comment[content]', with: ''
            click_button 'コメント投稿'
          end

          # エラーメッセージが表示されることを確認
          expect(page).to have_text('を入力してください')
        end

        it '300文字を超えるコメントは投稿できない', js: true do
          long_comment = 'あ' * 301
          
          within '#comment_form' do
            fill_in 'comment[content]', with: long_comment
            click_button 'コメント投稿'
          end

          # エラーメッセージが表示されることを確認
          expect(page).to have_text('は300文字以内で入力してください')
        end

        it 'コメント投稿後にコメント数が更新される', js: true do
          # 初期コメント数を確認
          initial_count = find('#comments_count').text.to_i

          comment_text = 'コメント数テスト'
          
          within '#comment_form' do
            fill_in 'comment[content]', with: comment_text
            click_button 'コメント投稿'
          end

          # Ajax処理を待機
          sleep 1

          # コメント数が増加していることを確認
          updated_count = find('#comments_count').text.to_i
          expect(updated_count).to eq(initial_count + 1)
        end
      end

      describe '文字数カウンター機能' do
        it 'テキスト入力時に文字数が更新される', js: true do
          test_text = 'テスト文字列'
          
          fill_in 'comment[content]', with: test_text
          
          expect(find('#comment_counter').text).to eq(test_text.length.to_s)
        end

        it '250文字以上で色が変わる', js: true do
          long_text = 'あ' * 250
          
          fill_in 'comment[content]', with: long_text
          
          counter = find('#comment_counter')
          expect(counter[:class]).to include('text-orange-600')
        end

        it '280文字以上で赤色になる', js: true do
          very_long_text = 'あ' * 285
          
          fill_in 'comment[content]', with: very_long_text
          
          counter = find('#comment_counter')
          expect(counter[:class]).to include('text-red-600')
        end
      end
    end

    context 'ログインしていないユーザーの場合' do
      before { visit post_path(post_record) }

      it 'コメントフォームが表示されない' do
        expect(page).not_to have_css('#comment_form')
        expect(page).not_to have_field('comment[content]')
      end

      it 'ログインを促すメッセージが表示される' do
        expect(page).to have_text('コメントを投稿するには')
        expect(page).to have_link('ログイン', href: new_user_session_path)
      end
    end
  end

  describe 'コメント表示機能' do
    let!(:comment1) { create(:comment, user: user, post: post_record, content: '最初のコメント') }
    let!(:comment2) { create(:comment, user: other_user, post: post_record, content: '二番目のコメント') }

    before do
      visit post_path(post_record)
    end

    it 'コメントが新しい順に表示される' do
      comments = page.all('#comments_list > div')
      expect(comments.first).to have_text('二番目のコメント')
      expect(comments.last).to have_text('最初のコメント')
    end

    it 'コメント作成者の名前が表示される' do
      within '#comments_list' do
        expect(page).to have_text(user.display_name)
        expect(page).to have_text(other_user.display_name)
      end
    end

    it 'コメント作成時間が表示される' do
      within '#comments_list' do
        expect(page).to have_css('[data-comment-id]')
      end
    end

    it 'コメント数が正確に表示される' do
      expect(find('#comments_count').text).to eq('2')
    end

    context 'コメントが存在しない場合' do
      let(:empty_post) { create(:post, user: user) }

      before { visit post_path(empty_post) }

      it '「コメントがありません」メッセージが表示される' do
        expect(page).to have_text('まだコメントがありません')
      end
    end
  end

  describe 'コメント削除機能' do
    let!(:user_comment) { create(:comment, user: user, post: post_record, content: 'ユーザーのコメント') }
    let!(:other_comment) { create(:comment, user: other_user, post: post_record, content: '他人のコメント') }

    context 'ログイン済みユーザーの場合' do
      before do
        sign_in user
        visit post_path(post_record)
      end

      it '自分のコメントに削除ボタンが表示される' do
        within "#comment_#{user_comment.id}" do
          expect(page).to have_css('a[title="コメントを削除"]')
        end
      end

      it '他人のコメントに削除ボタンが表示されない' do
        within "#comment_#{other_comment.id}" do
          expect(page).not_to have_css('a[title="コメントを削除"]')
        end
      end

      it '自分のコメントを削除できる', js: true do
        within "#comment_#{user_comment.id}" do
          # 確認ダイアログで「OK」をクリック
          accept_confirm do
            click_link title: 'コメントを削除'
          end
        end

        # Ajax処理を待機
        sleep 1

        # コメントが削除されることを確認
        expect(page).not_to have_css("#comment_#{user_comment.id}")
        expect(page).not_to have_text('ユーザーのコメント')
      end

      it 'コメント削除後にコメント数が更新される', js: true do
        # 初期コメント数を確認（2件）
        expect(find('#comments_count').text).to eq('2')

        within "#comment_#{user_comment.id}" do
          accept_confirm do
            click_link title: 'コメントを削除'
          end
        end

        # Ajax処理を待機
        sleep 1

        # コメント数が減少していることを確認
        expect(find('#comments_count').text).to eq('1')
      end
    end

    context 'ログインしていないユーザーの場合' do
      before { visit post_path(post_record) }

      it '削除ボタンが表示されない' do
        expect(page).not_to have_css('a[title="コメントを削除"]')
      end
    end
  end

  describe 'レスポンシブデザイン' do
    let!(:comment) { create(:comment, user: user, post: post_record) }

    before do
      sign_in user
      visit post_path(post_record)
    end

    it 'モバイル画面でも適切に表示される' do
      page.driver.browser.manage.window.resize_to(375, 667) # iPhone SE サイズ
      
      expect(page).to have_css('#comment_form')
      expect(page).to have_css('#comments_list')
      expect(page).to have_field('comment[content]')
    end
  end
end