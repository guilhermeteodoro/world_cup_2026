# frozen_string_literal: true

class Views::Sessions::New < Views::Base
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
            form(action: session_path, method: "post") do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

              FormField do
                FormFieldLabel { t(".email_label") }
                Input(type: :email, name: "email", required: true, autofocus: true, placeholder: t(".email_placeholder"))
              end

              div(class: "mt-6") do
                Button(type: :submit) { t(".submit") }
              end
            end

            p(class: "mt-4 text-sm text-muted-foreground") do
              plain "#{t(".no_account")} "
              a(href: new_registration_path, class: "text-primary hover:underline") { t(".register_link") }
            end
          end
        end
      end
    end
  end
end
