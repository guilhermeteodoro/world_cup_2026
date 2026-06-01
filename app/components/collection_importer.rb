# frozen_string_literal: true

class Components::CollectionImporter < Components::Base
  def view_template
    FormField do
      FormFieldLabel { t(".method_label") }
      Combobox do
        ComboboxTrigger(placeholder: t(".dump"))

        ComboboxPopover do
          ComboboxList do
            ComboboxItem do
              ComboboxRadio(name: "import_method", value: "dump", checked: true, data: { action: "change->import-form#toggle" })
              span { t(".dump") }
            end
            ComboboxItem do
              ComboboxRadio(name: "import_method", value: "manual", data: { action: "change->import-form#toggle" })
              span { t(".manual") }
            end
          end
        end
      end
    end

    div(data: { import_form_target: "dump" }) do
      FormField do
        div(class: "grid grid-flow-col items-center") do
          FormFieldLabel { t(".dump_label") }
          div(class: "justify-self-end") do
            render tutorial_dialog
          end
        end
        Textarea(name: "dump", rows: 4, placeholder: t(".dump_placeholder"), class: "font-mono text-sm")
      end
    end

    div(class: "hidden", data: { import_form_target: "manual" }) do
      FormField do
        FormFieldLabel { t(".missing_label") }
        Textarea(name: "missing_text", rows: 6, placeholder: t(".missing_placeholder"), class: "font-mono text-sm")
      end
      FormField do
        FormFieldLabel { t(".duplicates_label") }
        Textarea(name: "duplicates_text", rows: 6, placeholder: t(".duplicates_placeholder"), class: "font-mono text-sm")
      end
    end
  end

  private

  def tutorial_dialog
    Dialog do
      DialogTrigger do
        Text(size: "1", class: "italic text-muted-foreground hover:underline cursor-pointer") do
          t(".how_to_export")
        end
      end

      DialogContent(class: "bg-white") do
        DialogHeader do
          DialogTitle { t(".tutorial_title") }
          DialogDescription { "Settings > Backup/Restore collection > Create backup" }
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
