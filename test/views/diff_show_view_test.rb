# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class DiffShowViewTest < ActiveSupport::TestCase
  include ComponentTestHelper

  test "shows both list labels" do
    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results"))

    assert doc.at_css("label[for='list_a']")
    assert doc.at_css("label[for='list_b']")
  end

  test "shows only in list A results" do
    only_in_a = Sticker.includes(:country).where(position: [ 5, 6 ]).order(:position).to_a

    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results",
      only_in_a: only_in_a,
      only_in_b: []
    ))

    text = doc.text
    assert_includes text, I18n.t("views.diffs.show.only_in_a")
    only_in_a.each { |s| assert_includes text, s.number }
  end

  test "shows only in list B results" do
    only_in_b = Sticker.includes(:country).where(position: [ 21, 22 ]).order(:position).to_a

    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results",
      only_in_a: [],
      only_in_b: only_in_b
    ))

    text = doc.text
    assert_includes text, I18n.t("views.diffs.show.only_in_b")
    only_in_b.each { |s| assert_includes text, s.number }
  end

  test "shows empty state when lists are identical" do
    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results",
      only_in_a: [],
      only_in_b: []
    ))

    assert_includes doc.text, I18n.t("views.diffs.show.empty")
  end

  test "shows parse warnings" do
    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results",
      only_in_a: [],
      only_in_b: [],
      errors: [ "XXX 1", "BRA 99" ]
    ))

    text = doc.text
    assert_includes text, "XXX 1"
    assert_includes text, "BRA 99"
  end

  test "preserves textarea content after submission" do
    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results",
      list_a: "FWC: 00, 3",
      list_b: "BRA: 1, 5",
      only_in_a: [],
      only_in_b: []
    ))

    textarea_a = doc.at_css("textarea[name='list_a']")
    textarea_b = doc.at_css("textarea[name='list_b']")
    assert_includes textarea_a.text, "FWC: 00, 3"
    assert_includes textarea_b.text, "BRA: 1, 5"
  end

  test "sticker lists have copy buttons" do
    only_in_a = Sticker.includes(:country).where(position: [ 1, 2 ]).order(:position).to_a

    doc = render_document(Views::Diffs::Show.new(results_frame_id: "diff_results",
      only_in_a: only_in_a,
      only_in_b: []
    ))

    assert doc.at_css("[data-clipboard-text-value]"), "Should have copyable sticker list"
  end
end
