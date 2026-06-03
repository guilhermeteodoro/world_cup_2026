# frozen_string_literal: true

class Views::Users::Edit < Views::LoggedIn
  def page_title
    t(".title")
  end

  def render_title
    div(class: "grid") do
      div(class: "grid-row pt-1") do
        Breadcrumb do
          BreadcrumbList do
            BreadcrumbItem do
              BreadcrumbLink(href: user_path(@current_user)) { "Minha coleção" }
            end
          end
        end
      end

      div(class: "grid-row") do
        Heading(level: 2) { t(".title") }
      end
    end
  end

  def render_content
    div(class: "grid grid-flow-row sm:grid-flow-col") do
      div(class: "max-w-md space-y-6") do
        Card(class: "bg-white") do
          CardHeader do
            t(".form_title")
          end

          CardContent do
            form(action: user_path(@current_user), method: "post") do
              input(type: "hidden", name: "_method", value: "patch")
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

              FormField do
                FormFieldLabel { t(".name_label") }
                Input(type: "text", name: "name", required: true, value: @current_user.name)
              end

              FormField do
                FormFieldLabel { t(".email_label") }
                Input(type: "email", name: "email", required: true, value: @current_user.email)
              end

              div(class: "mt-6") do
                Button(type: :submit) { t(".submit") }
              end
            end
          end
        end
      end

      div(class: "justify-self-end") do
        div { render Components::LocaleSwitcher.new }
      end
    end
  end
end
