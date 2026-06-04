# frozen_string_literal: true

class UI::Fragments::UserMenu < UI::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div do
      Popover(options: { placement: "bottom-end" }) do
        PopoverTrigger do
          button(type: "button", class: "flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1.5 shadow-sm hover:bg-accent transition-colors") do
            span(class: "w-7 h-7 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm font-medium") do
              @user.name[0].upcase
            end
            span(class: "text-sm font-medium text-foreground") { @user.name }
          end
        end

        PopoverContent(class: "w-48") do
          div(class: "flex flex-col") do
            Link(href: user_path(@user), variant: :ghost, class: "w-full justify-start pl-2") do
              plain "👤 #{t(".my_collection")}"
            end
            Link(href: edit_user_path(@user), variant: :ghost, class: "w-full justify-start pl-2") do
              plain "⚙️ #{t(".settings")}"
            end
            Link(href: diff_path, variant: :ghost, class: "w-full justify-start pl-2") do
              plain "🔀 #{t(".diff")}"
            end
            div(class: "border-t my-1")
            form(action: session_path, method: "post") do
              input(type: "hidden", name: "_method", value: "delete")
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              button(type: "submit", class: "w-full text-left px-2 py-2 text-sm rounded-md hover:bg-accent transition-colors") do
                plain "🚪 #{t(".logout")}"
              end
            end
          end
        end
      end
    end
  end
end
