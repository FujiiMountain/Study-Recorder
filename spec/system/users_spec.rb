require "rails_helper"

RSpec.describe User, type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  describe "User CRUD" do
    describe "ログイン前" do
      describe "ユーザー新規登録" do
        context "入力内容有効" do
          it "新規登録成功" do
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: "example"
            fill_in "メールアドレス", with: "example@example.com"
            fill_in "user_password", with: "password1"
            fill_in "user_password_confirmation", with: "password1"
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq (before_count + 1)
            expect(ActionMailer::Base.deliveries.size).to eq 1
            expect(page).to have_content "メールを送りました"
            expect(current_path).to eq root_path
          end
        end

        context "入力内容無効" do
          it "名前無し" do
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: ""
            fill_in "メールアドレス", with: "example@example.com"
            fill_in "user_password", with: "password1"
            fill_in "user_password_confirmation", with: "password1"
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq before_count
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_user_path
          end

          it "メールアドレス無し" do
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: "example"
            fill_in "メールアドレス", with: ""
            fill_in "user_password", with: "password1"
            fill_in "user_password_confirmation", with: "password1"
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq before_count
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_user_path
          end

          it "メールアドレス重複" do
            old_user = User.new(name: "user", email: "user@example.com", password: "password1", password_confirmation: "password1")
            old_user.save
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: "user"
            fill_in "メールアドレス", with: "user@example.com"
            fill_in "user_password", with: "password1"
            fill_in "user_password_confirmation", with: "password1"
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq before_count
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_user_path
          end

          it "パスワード無し" do
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: "example"
            fill_in "メールアドレス", with: "example@example.com"
            fill_in "user_password", with: ""
            fill_in "user_password_confirmation", with: ""
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq before_count
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_user_path
          end

          it "パスワード確認無し" do
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: "example"
            fill_in "メールアドレス", with: "example@example.com"
            fill_in "user_password", with: "password1"
            fill_in "user_password_confirmation", with: ""                                                                           
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq before_count
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_user_path
          end
          it "パスワード不一致" do
            visit new_user_url
            before_count = User.count
            fill_in "名前", with: "example"
            fill_in "メールアドレス", with: "example@example.com"
            fill_in "user_password", with: "password1"
            fill_in "user_password_confirmation", with: "password2"
            click_button "登録"
            after_count = User.count
            expect(after_count).to eq before_count
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_user_path
          end
        end
      end
    end
    describe "ログイン後" do
      before do
        log_in(user)
      end
      describe "ユーザー編集" do
        before do
          visit edit_user_url(user)
        end
        context "編集成功" do
          it "名前" do
            update_name = "update"
            fill_in "名前", with: update_name
            click_on "更新"
            expect(page).to have_selector ".alert", text: "更新しました"
            expect(User.find(user.id).name).to eq update_name
            expect(current_path).to eq edit_user_path(user)
          end

          it "パスワード" do
            update_password = "update1234"
            fill_in "user_password", with: update_password
            fill_in "user_password_confirmation", with: update_password
            click_on "更新"
            expect(page).to have_selector ".alert", text: "更新しました"
            expect(BCrypt::Password.new(User.find(user.id).password_digest).is_password?(update_password)).to eq true
            expect(current_path).to eq edit_user_path(user)
          end

          # メール内リンクが実行環境ベースのリンクになっているため文字列を抽出、再生成している
          # -> ActionMailer設定を変更すればそのまま使える？
          it "メールアドレス" do
            update_email = "update@example.com"
            click_on "メールアドレス変更"
            fill_in "変更メールアドレス", with: update_email
            click_on "送信"
            expect(page).to have_selector ".alert", text: "パスワード変更用のメールを送りました"
            expect(ActionMailer::Base.deliveries.size).to eq 1
            ## メールデータから文字列を抽出してリンクを再生成している
            ## よりかんたんな方法がある場合変更を推奨 -> ActionMailer設定を変更すればOK?
            ## ここから
            linkOnMail = ActionMailer::Base.deliveries.last.html_part.body.match(/<a href=".*">/).to_s.split('"')[1]
            parts_linkOnMail = linkOnMail.split("/")
            getID = parts_linkOnMail[4]
            getChangeMail = parts_linkOnMail[5].match(/change_email=.*&/).to_s.split("=")[1].delete("&").sub("%40", "@")
            getMail = parts_linkOnMail[5].match(/email=.*/).to_s.split("=")[2].sub("%40", "@")
            ## ここまで
            visit edit_change_email_url(getID, change_email: getChangeMail, email: getMail)
            expect(page).to have_selector ".alert", text: "変更しました"
            expect(User.find(user.id).email).to eq update_email
            expect(current_path).to eq edit_user_path(user)
          end
        end

        context "編集失敗" do
          it "名前無し" do
            fill_in "名前", with: ""
            click_on "更新"
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq edit_user_path(user)
          end

          it "メールアドレス無し" do
            click_on "メールアドレス変更"
            fill_in "変更メールアドレス", with: ""
            click_on "送信"
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_change_email_path
          end

          it "メールアドレスエラー" do
            false_email = "fail"
            click_on "メールアドレス変更"
            fill_in "変更メールアドレス", with: false_email
            click_on "送信"
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq new_change_email_path
          end

          it "メールアドレス重複" do
            click_on "メールアドレス変更"
            fill_in "メールアドレス", with: other_user.email
            click_on "送信"
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector ".alert", text: "メールアドレスが登録されています"
            expect(current_path).to eq new_change_email_path
          end

          it "パスワード不一致" do
            fill_in "user_password", with: "password2"
            fill_in "user_password_confirmation", with: "password3"
            click_on "更新"
            expect(page).to have_selector ".alert", text: "エラーがあります"
            expect(current_path).to eq edit_user_path(user)
          end
        end
      end
      describe "ユーザー一覧" do
        context "admin: true" do
          it "ユーザー一覧へ移動成功" do
            admin_user = FactoryBot.create(:user, admin: true)
            log_in(admin_user)
            visit users_url
            expect(page).to have_selector "h1", text: "ユーザー一覧"
            expect(current_path).to eq users_path
          end
        end
        context "admin: false" do
          it "ユーザー一覧へ移動失敗" do
            visit users_url
            expect(page).to have_selector ".alert", text: "権限がありません"
            expect(current_path).to eq tasks_path
          end
        end
      end
      describe "ユーザー削除" do
        context "admin: true" do
          let(:admin_user) { FactoryBot.create(:user, admin: true) }
          
          before do
            log_in(admin_user)
          end

          it "ログインユーザーを削除成功" do
            visit edit_user_url(admin_user)
            before_count = User.count
            click_on "アカウント削除"
            page.accept_confirm "よろしいですか？"
            expect(page).to have_selector ".alert", text: "削除しました"
            after_count = User.count
            expect(after_count).to eq (before_count - 1)
            expect(current_path).to eq root_path
          end

          it "ログインユーザー以外を削除成功" do
            visit users_url
            before_count = User.count
            first("a", text: "削除").click
            page.accept_confirm "よろしいですか？"
            expect(page).to have_selector ".alert", text: "削除しました"
            after_count = User.count
            expect(after_count).to eq (before_count - 1)
            expect(current_path).to eq users_path
          end
        end
        context "admin: false" do
          before do
            log_in(user)
          end

          it "ログインユーザーを削除成功" do
            visit edit_user_url(user)
            before_count = User.count
            click_on "アカウント削除"
            page.accept_confirm "よろしいですか？"
            expect(page).to have_selector ".alert", text: "削除しました"
            after_count = User.count
            expect(after_count).to eq (before_count - 1)
            expect(current_path).to eq root_path
          end

          it "ログインユーザー以外を削除失敗" do
            visit users_url
            expect(page).to have_selector ".alert", text: "権限がありません"
            expect(current_path).to eq tasks_path
          end
        end
      end
    end
  end
  describe "User Activate" do
    context "有効化" do
      it "ユーザの有効化" do
        activate_user = FactoryBot.build(:user, name: "activate", email: "activate@example.com", activated: false)
        visit new_user_url
        before_count = User.count
        fill_in "名前", with: activate_user.name
        fill_in "メールアドレス", with: activate_user.email
        fill_in "user_password", with: "password1"
        fill_in "user_password_confirmation", with: "password1"
        click_button "登録"
        expect(page).to have_content "メールを送りました"
        expect(ActionMailer::Base.deliveries.size).to eq 1
        after_count = User.count
        expect(after_count).to eq (before_count + 1)
        ## メールデータから文字列を抽出してリンクを再生成している
        ## よりかんたんな方法がある場合変更を推奨 -> ActionMailer設定を変更すればOK?
        ## ここから
        linkOnMail = ActionMailer::Base.deliveries.last.html_part.body.match(/<a href=".*">/).to_s.split('"')[1]
        parts_linkOnMail = linkOnMail.split("/")
        getID = parts_linkOnMail[4]
        ## ここまで
        visit edit_account_activation_url(getID, email: activate_user.email)
        expect(page).to have_selector ".alert", text: "有効化しました"
        expect(current_path).to eq tasks_path
      end
    end

    context "有効化できない" do
      it "エラー" do
        activate_user = FactoryBot.build(:user, name: "activate", email: "activate@example.com", activated: false)
        visit new_user_url
        before_count = User.count
        fill_in "名前", with: activate_user.name
        fill_in "メールアドレス", with: activate_user.email
        fill_in "user_password", with: "password1"
        fill_in "user_password_confirmation", with: "password1"
        click_button "登録"
        expect(page).to have_content "メールを送りました"
        expect(ActionMailer::Base.deliveries.size).to eq 1
        after_count = User.count
        expect(after_count).to eq (before_count + 1)
        ## メールデータから文字列を抽出してリンクを再生成している
        ## よりかんたんな方法がある場合変更を推奨 -> ActionMailer設定を変更すればOK?                                                          
        ## ここから
        linkOnMail = ActionMailer::Base.deliveries.last.html_part.body.match(/<a href=".*">/).to_s.split('"')[1]
        parts_linkOnMail = linkOnMail.split("/")
        getID = parts_linkOnMail[4]
        ## ここまで
        visit edit_account_activation_url(getID, email: "fail@example.com")
        expect(page).to have_selector ".alert", text: "無効なリンクです"
        expect(current_path).to eq root_path
      end
    end
  end

  describe "User Password Reset" do
    context "パスワード変更" do
      it "変更成功" do
        change_password = "change1234"
        visit new_password_reset_url
        fill_in "メールアドレス", with: user.email
        click_on "送信"
        expect(page).to have_content "パスワード再設定用のメールを送りました"
        expect(ActionMailer::Base.deliveries.size).to eq 1
        ## メールデータから文字列を抽出してリンクを再生成している
        ## よりかんたんな方法がある場合変更を推奨 -> ActionMailer設定を変更すればOK?
        ## ここから
        linkOnMail = ActionMailer::Base.deliveries.last.html_part.body.match(/<a href=".*">/).to_s.split('"')[1]
        parts_linkOnMail = linkOnMail.split("/")
        getID = parts_linkOnMail[4]
        ## ここまで
        visit edit_password_reset_url(getID, email: user.email)
        fill_in "user_password", with: change_password
        fill_in "user_password_confirmation", with: change_password
        click_on "登録"
        expect(page).to have_selector ".alert", text: "パスワードを変更しました"
        expect(BCrypt::Password.new(User.find_by(email: user.email).password_digest).is_password?(change_password)).to eq true
        expect(current_path).to eq tasks_path
      end
    end

    context "パスワード変更失敗" do
      it "メールアドレスがない" do
        fail_email = "fail@example.com"
        visit new_password_reset_url
        fill_in "メールアドレス", with: fail_email
        click_on "送信"
        expect(page).to have_content "メールアドレスが見つかりませんでした"
        expect(ActionMailer::Base.deliveries.size).to eq 0
        expect(current_path).to eq new_password_reset_path
      end

      it "パスワードが空" do
        fail_password = ""
        visit new_password_reset_url
        fill_in "メールアドレス", with: user.email
        click_on "送信"
        expect(page).to have_content "パスワード再設定用のメールを送りました"
        expect(ActionMailer::Base.deliveries.size).to eq 1
        ## メールデータから文字列を抽出してリンクを再生成している
        ## よりかんたんな方法がある場合変更を推奨 -> ActionMailer設定を変更すればOK?
        ## ここから
        linkOnMail = ActionMailer::Base.deliveries.last.html_part.body.match(/<a href=".*">/).to_s.split('"')[1]
        parts_linkOnMail = linkOnMail.split("/")
        getID = parts_linkOnMail[4]
        ## ここまで
        visit edit_password_reset_url(getID, email: user.email)
        fill_in "user_password", with: fail_password
        fill_in "user_password_confirmation", with: fail_password
        click_on "登録"
        expect(page).to have_selector ".alert", text: "パスワードを入力してください"
        expect(current_path).to eq edit_password_reset_path(getID)
      end

      it "パスワードが不適" do
        fail_password = "changepassword"
        visit new_password_reset_url
        fill_in "メールアドレス", with: user.email
        click_on "送信"
        expect(page).to have_content "パスワード再設定用のメールを送りました"
        expect(ActionMailer::Base.deliveries.size).to eq 1
        ## メールデータから文字列を抽出してリンクを再生成している
        ## よりかんたんな方法がある場合変更を推奨 -> ActionMailer設定を変更すればOK?
        ## ここから
        linkOnMail = ActionMailer::Base.deliveries.last.html_part.body.match(/<a href=".*">/).to_s.split('"')[1]
        parts_linkOnMail = linkOnMail.split("/")
        getID = parts_linkOnMail[4]
        ## ここまで
        visit edit_password_reset_url(getID, email: user.email)
        fill_in "user_password", with: fail_password
        fill_in "user_password_confirmation", with: fail_password
        click_on "登録"
        expect(page).to have_selector ".alert", text: "エラーがあります"
        expect(current_path).not_to eq tasks_path
        expect(BCrypt::Password.new(User.find_by(email: user.email).password_digest).is_password?(fail_password)).not_to eq true
        expect(current_path).to eq edit_password_reset_path(getID)
      end
    end
  end
end
