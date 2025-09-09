require 'rails_helper'

RSpec.describe Like, type: :model do
  describe "associations" do
    it "belongs to user" do
      user = create(:user)
      post_record = create(:post)
      like = create(:like, user: user, post: post_record)
      
      expect(like.user).to eq(user)
      expect(like.user).to be_a(User)
    end
    
    it "belongs to post" do
      user = create(:user)
      post_record = create(:post)
      like = create(:like, user: user, post: post_record)
      
      expect(like.post).to eq(post_record)
      expect(like.post).to be_a(Post)
    end
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:post_record) { create(:post) }
    
    it "should be valid with user and post" do
      like = build(:like, user: user, post: post_record)
      expect(like).to be_valid
    end
    
    it "should not allow duplicate likes from same user on same post" do
      create(:like, user: user, post: post_record)
      duplicate_like = build(:like, user: user, post: post_record)
      expect(duplicate_like).not_to be_valid
      expect(duplicate_like.errors[:user_id]).to include("既にこの投稿にいいねしています")
    end
    
    it "should allow likes from different users on same post" do
      user2 = create(:user, display_name: "ユーザー2", email: "user2@example.com")
      create(:like, user: user, post: post_record)
      like_from_different_user = build(:like, user: user2, post: post_record)
      expect(like_from_different_user).to be_valid
    end
    
    it "should allow likes from same user on different posts" do
      post2 = create(:post, title: "投稿2")
      create(:like, user: user, post: post_record)
      like_on_different_post = build(:like, user: user, post: post2)
      expect(like_on_different_post).to be_valid
    end
  end
  
  describe "database constraints" do
    it "should enforce unique index on user_id and post_id" do
      user = create(:user)
      post_record = create(:post)
      create(:like, user: user, post: post_record)
      
      expect {
        # データベースレベルでの重複チェック（バリデーションを迂回）
        Like.new(user: user, post: post_record).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
