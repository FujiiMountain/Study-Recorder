require 'rails_helper'

RSpec.describe User, type: :model  do
  let(:user) { FactoryBot.build(:user) }

  context "有効" do
    it "name, email, password" do
      expect(user.save).to be_truthy
    end
  end

  context "メールアドレスが無効" do
    it "nil" do
      user.email = nil
      expect(user.save).to be_falsey
    end

    it "abcdefg" do
      user.email = "abcdefg"
      expect(user.save).to be_falsey
    end

    it "abc@abc" do
      user.email = "abc@abc"
      expect(user.save).to be_falsey
    end
    it "@example.com" do
      user.email = "@example.com"
      expect(user.save).to be_falsey
    end

    it "a!d@example.com" do
      user.email = "a!d@example.com"
      expect(user.save).to be_falsey
    end
  end
  
  context "パスワードが無効" do
    it "nil" do
      user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
      expect(user.save).to be_falsey

      user = FactoryBot.build(:user, password: "pass1", password_confirmation: "pass1")
      expect(user.save).to be_falsey

      user = FactoryBot.build(:user, password: "password", password_confirmation: "password")
      expect(user.save).to be_falsey

      user = FactoryBot.build(:user, password_confirmation: "password2")
      expect(user.save).to be_falsey

      user = FactoryBot.build(:user, password: "password2")
      expect(user.save).to be_falsey
    end
  end

  it "メールアドレスが重複している" do
    FactoryBot.create(:user, email: "example@example.com")
    thisuser = FactoryBot.build(:user, email: "example@example.com")
    expect(thisuser.save).to be_falsey
  end

  it "パスワードが暗号化されている" do
    expect(user.password_digest).not_to eq user.password
  end
end
