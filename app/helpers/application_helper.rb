module ApplicationHelper
  def indent(text, spaces = 2)
    text.lines.map { |l| "#{" " * spaces}#{l}" }.join
  end
end
