# frozen_string_literal: true

class Views::Registrations::New < Views::Base
  def initialize(email: nil)
    @email = email
  end

  def view_template
    div(class: "max-w-md mx-auto") do
      Card do
        CardHeader do
          CardTitle { t("registrations.new.title") }
        end
        CardContent do
          form(action: registration_path, method: "post", data: { controller: "import-form" }) do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

            FormField do
              FormFieldLabel { t("registrations.new.name_label") }
              Input(type: "text", name: "name", required: true, placeholder: t("registrations.new.name_placeholder"))
            end

            FormField do
              FormFieldLabel { t("registrations.new.email_label") }
              Input(type: "email", name: "email", required: true, value: @email, placeholder: t("registrations.new.email_placeholder"))
            end

            render_import_fields

            div(class: "mt-6") do
              Button(type: :submit) { t("registrations.new.submit") }
            end
          end
        end
      end
    end
  end

  private

  def render_import_fields
    FormField do
      FormFieldLabel { t("registrations.new.import_method_label") }
      div(class: "flex gap-4") do
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "dump",
                checked: true, data: { action: "import-form#toggle" })
          span(class: "text-sm") { t("registrations.new.import_dump") }
        end
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "manual",
                data: { action: "import-form#toggle" })
          span(class: "text-sm") { t("registrations.new.import_manual") }
        end
      end
    end

    div(data: { import_form_target: "dump" }) do
      FormField do
        FormFieldLabel { t("registrations.new.dump_label") }
        Textarea(name: "dump", rows: 4, placeholder: t("registrations.new.dump_placeholder"), class: "font-mono text-sm")
      end
    end

    div(class: "hidden", data: { import_form_target: "manual" }) do
      FormField do
        FormFieldLabel { t("registrations.new.missing_label") }
        Textarea(name: "missing_text", rows: 6, placeholder: t("registrations.new.missing_placeholder"), class: "font-mono text-sm")
      end
      FormField do
        FormFieldLabel { t("registrations.new.duplicates_label") }
        Textarea(name: "duplicates_text", rows: 6, placeholder: t("registrations.new.duplicates_placeholder"), class: "font-mono text-sm")
      end
    end
  end
end
