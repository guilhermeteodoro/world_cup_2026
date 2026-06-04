# frozen_string_literal: true

class Views::Trades::Export < UI::Base
  def initialize(trade:, dump:, missing:, duplicates:, current_user:)
    @trade = trade
    @dump = dump
    @missing = missing
    @duplicates = duplicates
    @current_user = current_user
  end

  def view_template
    turbo_frame(id: "export_trade_#{@trade.id}") do
      div(data: { controller: "import-form" }) do
        render_format_selector
        render_dump_section
        render_manual_section
      end
    end
  end

  private

  def render_format_selector
    FormField do
      FormFieldLabel { t(".format_label") }
      Combobox do
        ComboboxTrigger(placeholder: t(".dump"))

        ComboboxPopover do
          ComboboxList do
            ComboboxItem do
              ComboboxRadio(name: "export_method", value: "dump", checked: true, data: { action: "change->import-form#toggle" })
              span { t(".dump") }
            end
            ComboboxItem do
              ComboboxRadio(name: "export_method", value: "manual", data: { action: "change->import-form#toggle" })
              span { t(".manual") }
            end
          end
        end
      end
    end
  end

  def render_dump_section
    div(data: { import_form_target: "dump" }) do
      FormField do
        FormFieldLabel { t(".dump_label") }
        Textarea(readonly: true, rows: 4, class: "font-mono text-xs") { @dump }
      end
      copy_button(@dump)
    end
  end

  def render_manual_section
    div(class: "hidden", data: { import_form_target: "manual" }) do
      FormField do
        FormFieldLabel { t(".missing_label") }
        Textarea(readonly: true, rows: 6, class: "font-mono text-xs") { @missing }
      end
      copy_button(@missing)

      div(class: "mt-4") do
        FormField do
          FormFieldLabel { t(".duplicates_label") }
          Textarea(readonly: true, rows: 6, class: "font-mono text-xs") { @duplicates }
        end
        copy_button(@duplicates)
      end
    end
  end

  def copy_button(text)
    div(class: "mt-2 flex justify-end", data: { controller: "clipboard", clipboard_text_value: text }) do
      Button(variant: :outline, size: :sm, type: "button", data: { action: "clipboard#copy", copy_button: "" }) { t(".copy") }
    end
  end
end
