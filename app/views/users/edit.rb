# frozen_string_literal: true

class Views::Users::Edit < Views::LoggedIn
  def render_title
    div(class: "grid") do
      div(class: "grid-row") do
        Heading(level: 2) { t("users.edit.title") }
      end

      div(class: "grid-row") do
        Link(href: user_path(@current_user), class: "p-0") { Text(size: "1") {  "< Minha coleção" } }
      end
    end
  end

  def render_content
    div(class: "max-w-md") do
      Card(class: "bg-white") do
        CardHeader do
          "Cadastro"
        end

        CardContent do
          form(action: user_path(@current_user), method: "post") do
            input(type: "hidden", name: "_method", value: "patch")
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            FormField do
              FormFieldLabel { t("users.edit.name_label") }
              Input(type: "text", name: "name", required: true, value: @current_user.name)
            end

            FormField do
              FormFieldLabel { t("users.edit.email_label") }
              Input(type: "email", name: "email", required: true, value: @current_user.email)
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
