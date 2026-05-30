# frozen_string_literal: true

class Views::Users::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div(class: "max-w-md mx-auto") do
      Card do
        CardHeader do
          CardTitle { t("users.edit.title") }
        end
        CardContent do
          form(action: user_path(@user), method: "post") do
            input(type: "hidden", name: "_method", value: "patch")
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            FormField do
              FormFieldLabel { t("users.edit.name_label") }
              Input(type: "text", name: "name", required: true, value: @user.name)
            end

            FormField do
              FormFieldLabel { t("users.edit.email_label") }
              Input(type: "email", name: "email", required: true, value: @user.email)
            end

            div(class: "mt-6") do
              Button(type: :submit) { t("users.edit.submit") }
            end
          end
        end
      end
    end
  end
end
