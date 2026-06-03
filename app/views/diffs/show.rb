# frozen_string_literal: true

class Views::Diffs::Show < Views::Base
  def initialize(current_user: nil, list_a: nil, list_b: nil, only_in_a: nil, only_in_b: nil, errors: nil)
    @current_user = current_user
    @list_a = list_a || ""
    @list_b = list_b || ""
    @only_in_a = only_in_a
    @only_in_b = only_in_b
    @errors = errors || []
  end

  def page_title
    t(".title")
  end

  def view_template
    div(class: "pt-6 pb-2 px-2") do
      div(class: "flex items-top gap-2 mb-6 space-between") do
        div(class: "grow-1") do
          Heading(level: 2) { t(".title") }
          p(class: "text-muted-foreground text-sm mt-1") { t(".subtitle") }
        end

        div(class: "grow-0") do
          render Components::UserMenu.new(user: @current_user) if @current_user
        end
      end

      render_form
      render_errors if @errors.any?
      render_results if @only_in_a || @only_in_b
    end
  end

  private

  def render_form
    form(action: diff_path, method: "post", class: "space-y-4") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

      div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
        div do
          label(for: "list_a", class: "block text-sm font-medium mb-1") { t(".list_a_label") }
          textarea(
            name: "list_a",
            id: "list_a",
            rows: 10,
            class: "w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring",
            placeholder: t(".placeholder")
          ) { @list_a }
        end

        div do
          label(for: "list_b", class: "block text-sm font-medium mb-1") { t(".list_b_label") }
          textarea(
            name: "list_b",
            id: "list_b",
            rows: 10,
            class: "w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring",
            placeholder: t(".placeholder")
          ) { @list_b }
        end
      end

      div do
        Button(variant: :primary, type: "submit") { t(".submit") }
      end
    end
  end

  def render_errors
    Alert(class: "mt-4") do
      AlertDescription do
        plain "#{t(".parse_warning")}: #{@errors.join(", ")}"
      end
    end
  end

  def render_results
    div(class: "mt-8 space-y-6") do
      render_diff_section(t(".only_in_a"), @only_in_a)
      render_diff_section(t(".only_in_b"), @only_in_b)
    end
  end

  def render_diff_section(title, stickers)
    div do
      Heading(level: 3, class: "mb-2") { title }
      if stickers.any?
        render Components::StickerList.new(stickers: stickers, copyable: true)
      else
        p(class: "text-sm text-muted-foreground") { t(".empty") }
      end
    end
  end
end
