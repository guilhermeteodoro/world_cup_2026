# frozen_string_literal: true

class Components::Nav < Components::Base
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def view_template
    nav(class: "bg-white shadow-sm border-b") do
      div(class: "max-w-4xl mx-auto px-4 py-3 flex items-center justify-between") do
        a(href: root_path, class: "text-xl font-bold text-green-700") { t("app_name") }

        div(class: "flex items-center gap-4 text-sm") do
          if @current_user
            a(href: user_path(@current_user), class: "text-gray-600 hover:text-gray-900") { @current_user.name }
            button(form: "logout-form", type: "submit", class: "text-gray-500 hover:text-gray-700") { t("nav.logout") }
          else
            a(href: new_session_path, class: "text-gray-600 hover:text-gray-900") { t("nav.login") }
            a(href: new_registration_path, class: "bg-green-600 text-white px-3 py-1 rounded font-medium hover:bg-green-700") { t("nav.register") }
          end
        end
      end
    end

    if @current_user
      form(id: "logout-form", action: session_path, method: "post", class: "hidden") do
        input(type: "hidden", name: "_method", value: "delete")
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      end
    end
  end

end
