# frozen_string_literal: true

class Views::Registrations::New < Views::Base
  def initialize(email: nil)
    @email = email
  end

  def page_title
    t(".title")
  end

  def view_template
    div(class: "flex min-h-screen items-center") do
      div(class: "max-w-lg grow-1 mx-auto p-2") do
        Card(class: "bg-white") do
          CardHeader do
            CardTitle { t(".title") }
          end

          CardContent do
            form(action: registration_path, method: "post", data: { controller: "import-form" }) do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

              FormField do
                FormFieldLabel { t(".name_label") }
                Input(type: :text, name: "name", required: true, placeholder: t(".name_placeholder"))
              end

              FormField do
                FormFieldLabel { t(".email_label") }
                Input(type: :email, name: "email", required: true, value: @email, placeholder: t(".email_placeholder"))
              end

              render Components::CollectionImporter.new

              div(class: "mt-6") do
                Button(type: :submit) { t(".submit") }
              end
            end

            p(class: "mt-4 text-sm text-muted-foreground") do
              plain "#{t(".has_account")} "
              a(href: new_session_path, class: "text-primary hover:underline") { t(".login_link") }
            end
          end
        end
      end
    end
  end
end
