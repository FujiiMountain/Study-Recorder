require "rails_helper"

RSpec.describe Task, type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  describe "Task CRUD" do
    describe "新規作成" do
      context "入力内容有効" do
        it "作成成功" do
          log_in user
          visit new_task_url
          fill_in "日付", with: "2021-03-01"
          fill_in "名称", with: "プログラミング"
          fill_in "時間", with: "5.5"
          click_on "登録"
          expect(page).to have_selector ".alert", text: "登録しました"
          expect(current_path).to eq tasks_path
        end
      end

      context "入力内容無効" do
        it "日付が無効" do
          log_in user
          visit new_task_url
          fill_in "日付", with: "0000"
          fill_in "名称", with: "プログラミング"
          fill_in "時間", with: "5.5"
          click_on "登録"
          expect(page).to have_selector ".alert", text: "エラーがあります"
          expect(current_path).to eq new_task_path
        end

        it "名称が無効" do
          log_in user
          visit new_task_url
          fill_in "日付", with: "2021-03-01"
          fill_in "名称", with: ""
          fill_in "時間", with: "5.5"
          click_on "登録"
          expect(page).to have_selector ".alert", text: "エラーがあります"
          expect(current_path).to eq new_task_path
        end

        it "時間が無効" do
          log_in user
          visit new_task_url
          fill_in "日付", with: "2021-03-01"
          fill_in "名称", with: "プログラミング"
          fill_in "時間", with: "25"
          click_on "登録"
          expect(page).to have_selector ".alert", text: "エラーがあります"
          expect(current_path).to eq new_task_path
        end
      end
    end
    describe "一覧" do
      before do
        log_in(user)
        6.times do
          FactoryBot.create(:task, user_id: user.id)
        end
      end

      context "タスクが見える" do
        it "タスクがある" do
          visit task_url(user)
          expect(page).to have_selector ".pagination", text: 1
          expect(page).to have_selector ".pagination", text: 2
          expect(current_path).to eq task_path(user.id)
        end
      end

      context "タスクが見えない" do
        it "タスクを作っていないユーザのタスクがない" do
          log_in(other_user)
          visit task_url(other_user)
          expect(page).not_to have_selector "nav.pagination", text: 1
          expect(current_path).to eq task_path(other_user.id)
        end

        it "タスクを作ったユーザのタスクが他のユーザには見えない" do
          log_in(other_user)
          visit task_url(user)
          expect(page).not_to have_selector "nav.pagination", text: 1
          expect(current_path).to eq task_path(user.id)
        end
      end
    end

    describe "編集" do
      before do
        log_in(user)
        task = FactoryBot.create(:task, user_id: user.id)
      end

      context "編集成功" do
        it "日付" do
          update_date = "2030-01-01"
          target = Task.find_by(user_id: user.id)
          visit edit_task_url(target)
          fill_in "日付", with: update_date
          click_on "更新"
          expect(page).to have_selector ".alert", text: "更新しました"
          expect(Task.find(target.id).date.strftime("%Y-%m-%d")).to eq update_date
          expect(current_path).to eq edit_task_path(target)
        end

        it "名称" do
          update_name = "アップデート"
          target = Task.find_by(user_id: user.id)
          visit edit_task_url(target)
          fill_in "名称", with: update_name
          click_on "更新"
          expect(page).to have_selector ".alert", text: "更新しました"
          expect(Task.find(target.id).name).to eq update_name
          expect(current_path).to eq edit_task_path(target)
        end

        it "時間" do
          update_amount = "20".to_f
          target = Task.find_by(user_id: user.id)
          visit edit_task_url(target)
          fill_in "時間", with: update_amount
          click_on "更新"
          expect(page).to have_selector ".alert", text: "更新しました"
          expect(Task.find(target.id).amount).to eq update_amount
          expect(current_path).to eq edit_task_path(target)
        end
      end

      context "編集失敗" do
        it "日付" do
          update_date = "0000"
          target = Task.find_by(user_id: user.id)
          visit edit_task_url(target)
          fill_in "日付", with: update_date
          click_on "更新"
          expect(page).to have_selector ".alert", text: "エラーがあります"
          expect(Task.find(target.id).date.strftime("%Y-%m-%d")).not_to eq update_date
          expect(current_path).to eq edit_task_path(target)
        end 

        it "名称" do
          update_name = ""
          target = Task.find_by(user_id: user.id)
          visit edit_task_url(target)
          fill_in "名称", with: update_name
          click_on "更新"
          expect(page).to have_selector ".alert", text: "エラーがあります"
          expect(Task.find(target.id).name).not_to eq update_name
          expect(current_path).to eq edit_task_path(target)
        end

        it "時間" do
          update_amount = "25".to_f
          target = Task.find_by(user_id: user.id)
          visit edit_task_url(target)
          fill_in "時間", with: update_amount
          click_on "更新"
          expect(page).to have_selector ".alert", text: "エラーがあります"
          expect(Task.find(target.id).amount).not_to eq update_amount
          expect(current_path).to eq edit_task_path(target)
        end
      end
    end
    describe "削除" do
      before do
        log_in(user)
        3.times { task = FactoryBot.create(:task, user_id: user.id) }
      end
      context "削除成功" do
        it "一覧から削除" do
          visit task_url(user)
          before_count = user.tasks.count
          expect(page).to have_selector ".btn-danger"
          first(".delete_button").click_on "削除"
          expect(page).to have_selector ".alert", text: "削除しました"
          after_count = user.tasks.count
          expect(after_count).to (eq before_count - 1)
          expect(current_path).to eq task_path(user)
        end

        it "作成・確認から削除" do
          target_date = user.tasks.first.date
          visit new_task_url(date: target_date)
          before_count = user.tasks.count
          expect(page).to have_selector ".btn-danger"
          first(".delete_button").click_on "削除"
          expect(page).to have_selector ".alert", text: "削除しました"
          after_count = user.tasks.count
          expect(after_count).to (eq before_count - 1)
          # pathではクエリにdateを入れれない？
          # expect(current_path).to eq new_task_path(date: target_date)
          # 日付formの日付が適切か確認
          expect(page).to have_field "日付", with: target_date
          expect(current_path).to eq new_task_path
        end
      end

      context "削除失敗（ボタンがない）" do
        it "一覧の削除ボタン" do
          log_in(other_user)
          visit task_url(user)
          expect(page).not_to have_selector ".list-group-item", text: "削除"
          expect(current_path).to eq task_path(user)
        end
        it "作成・確認の削除ボタン" do
          log_in(other_user)
          visit new_task_url(date: user.tasks.first.date)
          expect(page).not_to have_selector ".list-group-item", text: "削除"
          # pathではクエリにdateを入れれない？
          # expect(current_path).to eq new_task_path(date: user.tasks.first.date)
          # 日付formの日付が適切か確認
          expect(page).to have_field "日付", with: user.tasks.first.date
          expect(current_path).to eq new_task_path
        end
      end
    end
  end

  describe "ユーザ削除で連動してそのタスクを削除" do
    it "ユーザ削除タスク削除連動" do
      log_in(user)
      3.times { FactoryBot.create(:task, user_id: user.id) }
      before_count = Task.count
      visit edit_user_url(user.id)
      click_on "アカウント削除"
      page.accept_confirm "よろしいですか？"
      expect(page).to have_selector ".alert", text: "削除しました"
      after_count = Task.count
      expect(after_count).to eq (before_count - 3)
      expect(current_path).to eq root_path
    end
  end
end
