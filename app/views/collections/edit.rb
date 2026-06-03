# frozen_string_literal: true

class Views::Collections::Edit < Views::LoggedIn
  def page_title
    t(".title")
  end

  def render_title
    div(class: "grid") do
      div(class: "grid-row pt-1") do
        Breadcrumb do
          BreadcrumbList do
            BreadcrumbItem do
              BreadcrumbLink(href: user_path(@current_user)) { t(".breadcrumb") }
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
    div(class: "max-w-md space-y-6") do
      Card(class: "bg-white") do
        CardHeader do
          t(".form_title")
        end

        CardContent do
          form(action: user_collection_path(@current_user), method: "post", data: { controller: "import-form" }) do
            input(type: "hidden", name: "_method", value: "patch")
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            render Components::CollectionImporter.new

            div(class: "mt-6") do
              Button(type: :submit) { t(".submit") }
            end
          end

          p(class: "mt-4 text-sm text-muted-foreground") { t(".warning") }
        end
      end
    end
  end
end
