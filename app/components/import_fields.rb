# frozen_string_literal: true

class Components::ImportFields < Components::Base
  def view_template
    FormField do
      FormFieldLabel { t("views.components.import_fields.method_label") }
      Combobox do
        ComboboxTrigger(placeholder: t("views.components.import_fields.dump"))

        ComboboxPopover do
          ComboboxList do
            ComboboxItem do
              ComboboxRadio(name: "import_method", value: "dump", checked: true, data: { action: "change->import-form#toggle" })
              span { t("views.components.import_fields.dump") }
            end
            ComboboxItem do
              ComboboxRadio(name: "import_method", value: "manual", data: { action: "change->import-form#toggle" })
              span { t("views.components.import_fields.manual") }
            end
          end
        end
      end
    end

    div(data: { import_form_target: "dump" }) do
      p(class: "text-sm text-primary hover:underline cursor-pointer mb-3") do
        render tutorial_dialog
      end

      FormField do
        FormFieldLabel { t("views.components.import_fields.dump_label") }
        Textarea(name: "dump", rows: 4, placeholder: t("views.components.import_fields.dump_placeholder"), class: "font-mono text-sm")
      end
    end

    div(class: "hidden", data: { import_form_target: "manual" }) do
      FormField do
        FormFieldLabel { t("views.components.import_fields.missing_label") }
        Textarea(name: "missing_text", rows: 6, placeholder: t("views.components.import_fields.missing_placeholder"), class: "font-mono text-sm")
      end
      FormField do
        FormFieldLabel { t("views.components.import_fields.duplicates_label") }
        Textarea(name: "duplicates_text", rows: 6, placeholder: t("views.components.import_fields.duplicates_placeholder"), class: "font-mono text-sm")
      end
    end
  end

  private

  def tutorial_dialog
    Dialog do
      DialogTrigger do
        span(class: "text-sm text-primary hover:underline") { t("views.components.import_fields.how_to_export") }
      end

      DialogContent do
        DialogHeader do
          DialogTitle { t("views.components.import_fields.tutorial_title") }
        end

        DialogMiddle do
          video(
            src: "/videos/sticker_album_2026.mp4",
            autoplay: true,
            muted: true,
            loop: true,
            playsinline: true,
            class: "w-full max-h-[70vh] object-contain rounded-lg"
          )
        end
      end
    end
  end
end
