# frozen_string_literal: true

class Views::Collections::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div(class: "max-w-lg mx-auto") do
      Card do
        CardHeader do
          CardTitle { t("collections.edit.title") }
        end
        CardContent do
          form(action: user_collection_path(@user), method: "post", data: { controller: "import-form" }) do
            input(type: "hidden", name: "_method", value: "patch")
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            render_import_fields

            div(class: "mt-6") do
              Button(type: :submit) { t("collections.edit.submit") }
            end
          end

          p(class: "mt-4 text-sm text-muted-foreground") { t("collections.edit.warning") }
        end
      end
    end
  end

  private

  def render_import_fields
    FormField do
      FormFieldLabel { t("collections.edit.import_method_label") }
      div(class: "flex gap-4") do
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "dump",
                checked: true, data: { action: "import-form#toggle" })
          span(class: "text-sm") { t("collections.edit.import_dump") }
        end
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "manual",
                data: { action: "import-form#toggle" })
          span(class: "text-sm") { t("collections.edit.import_manual") }
        end
      end
    end

    div(data: { import_form_target: "dump" }) do
      FormField do
        FormFieldLabel { t("collections.edit.dump_label") }
        Textarea(name: "dump", rows: 4, placeholder: t("collections.edit.dump_placeholder"), class: "font-mono text-sm")
      end
    end

    div(class: "hidden", data: { import_form_target: "manual" }) do
      FormField do
        FormFieldLabel { t("collections.edit.missing_label") }
        Textarea(name: "missing_text", rows: 6, placeholder: t("collections.edit.missing_placeholder"), class: "font-mono text-sm")
      end
      FormField do
        FormFieldLabel { t("collections.edit.duplicates_label") }
        Textarea(name: "duplicates_text", rows: 6, placeholder: t("collections.edit.duplicates_placeholder"), class: "font-mono text-sm")
      end
    end
  end
end
