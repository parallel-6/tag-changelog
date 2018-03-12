module TagChangelog
  class MessageList
    attr_reader :messages, :grouped

    def initialize(messages = [], grouped = true)
      @messages = messages
      @grouped = grouped
    end

    def to_text
      if grouped
        messages.map do |category|
          category["messages"].any? ? print_category(category) : nil
        end.reject(&:nil?).join("")
      else
        print_lines(messages).reject(&:nil?).join("")
      end
    end

    def print_category(category)
      [
        "#### #{category['header']}",
        print_lines(category["messages"]).join(""),
      ].join("\n")
    end

    def print_lines(lines)
      lines.map { |line| "* #{line}\n" }
    end
  end
end
