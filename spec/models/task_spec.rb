require "rails_helper"

RSpec.describe Task, type: :model do
  let(:task) { FactoryBot.build(:task) }

  it "date（Date）, name, amountが有効" do
    expect(task.save).to be_truthy
  end
  
  it "date（String）, name, amountが有効" do
    task.date= "2021-01-01"
    expect(task.save).to be_truthy
  end

  it "associationが作用" do
    expect(task.user_id).to be_truthy
  end

  context "dateが無効" do
  # dateはvalidatesのformatに適合しない場合でも以下の場合は自動で予測して適合するformatに変形する
  # 桁数が8桁もしくは数列(1-3桁)-数列(1-3桁)-数列(1-3桁)
  # ex. 20210101 →  2021-01-01, 1-1-1 →  0001-01-01
    it "nil" do
      task.date = nil
      expect(task.save).to be_falsey
    end

    it "---" do
      task.date = "---"
      expect(task.save).to be_falsey
    end

    it "00月" do
      task.date = "2021-00-01"
      expect(task.save).to be_falsey
    end

    it "13月" do
      task.date = "2021-13-01"
      expect(task.save).to be_falsey
    end

    it "111月" do
      task.date = "2021-111-01"
      expect(task.save).to be_falsey
    end

    it "00日" do
      task.date = "2021-01-00"
      expect(task.save).to be_falsey
    end

    it "32日" do
      task.date = "2021-01-32"
      expect(task.save).to be_falsey
    end

    it "111日" do
      task.date = "2021-01-111"
      expect(task.save).to be_falsey
    end

    it "20211年" do
      task.date = "20211-01-01"
      expect(task.save).to be_falsey
    end
  end

  context "nameが無効" do
    it "nil" do
      task.name = nil
      expect(task.save).to be_falsey
    end
  end

  context "amountが無効" do
    it "nil" do
      task.amount = nil
      expect(task.save).to be_falsey
    end

    it "0.01" do
      task.amount = 0.01
      expect(task.save).to be_falsey
    end

    it "10.01" do
      task.amount = 10.01
      expect(task.save).to be_falsey
    end

    it "24.1" do
      task.amount = 24.1
      expect(task.save).to be_falsey
    end

    it "100" do
      task.amount = 100
      expect(task.save).to be_falsey
    end
  end
end
