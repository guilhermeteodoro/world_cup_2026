# frozen_string_literal: true

class Views::Collections::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    h1(class: "text-2xl font-bold text-gray-900 mb-6") { t("collections.edit.title") }

    form(action: user_collection_path(@user), method: "post", data: { controller: "import-form" }) do
      input(type: "hidden", name: "_method", value: "patch")
      authenticity_token_tag

      render_import_fields

      div(class: "mt-6") do
        button(type: "submit", class: "bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          t("collections.edit.submit")
        end
      end
    end

    p(class: "mt-4 text-sm text-gray-500") { t("collections.edit.warning") }
  end

  private

  def render_import_fields
    div(class: "mb-6") do
      label(class: "block text-sm font-medium text-gray-700 mb-2") { t("collections.edit.import_method_label") }
      div(class: "flex gap-4") do
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "dump",
                checked: true, data: { action: "import-form#toggle" })
          span { t("collections.edit.import_dump") }
        end
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "manual",
                data: { action: "import-form#toggle" })
          span { t("collections.edit.import_manual") }
        end
      end
    end

    div(data: { import_form_target: "dump" }) do
      label(class: "block text-sm font-medium text-gray-700 mb-1") { t("collections.edit.dump_label") }
      textarea(
        name: "dump", rows: 4,
        class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
        placeholder: t("collections.edit.dump_placeholder")
      )
    end

    div(class: "hidden", data: { import_form_target: "manual" }) do
      div(class: "mb-4") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("collections.edit.missing_label") }
        textarea(
          name: "missing_text", rows: 6,
          class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
          placeholder: t("collections.edit.missing_placeholder")
        )
      end
      div do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("collections.edit.duplicates_label") }
        textarea(
          name: "duplicates_text", rows: 6,
          class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
          placeholder: t("collections.edit.duplicates_placeholder")
        )
      end
    end
  end

  def authenticity_token_tag
    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
  end
end
