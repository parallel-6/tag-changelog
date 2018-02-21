# A class to manipulate output destination of changelog and to write its contents.
module Changelog
  class Generate
    def self.run(options)
      new(options).run
    end

    def initialize(options = {})
      @options = options
      @output = open_output_file
      @tags_list = build_tags_list(options)
      @filter = Regexp.new(options[:filter], true)
      @commit_messages_filter = set_commits_filter(options)
      @group = options[:group]
    end

    def run
      output << "# Changelog\n\n"
      tags_list.each_cons(2) do |current_tag, previous_tag|
        tag = Git::Tag.new(current_tag)
        messages = get_commit_messages(previous_tag, current_tag)
        output << "## #{tag.version}" + " (#{tag.date})\n"
        output << messages.to_text
        output << "\n"
      end
    end

    private

    attr_reader :options,
                :output,
                :tags_list,
                :filter,
                :commit_messages_filter,
                :group

    def output_file_exists?
      File.exists?(options[:output])
    end

    def open_output_file
      puts "#{options[:output]} doesn't exist in #{options[:dir]}... creating it" unless output_file_exists?
      File.open(options[:output], "w+")
    end

    def build_tags_list(options)
      Git::TagList.new(options[:head]).list.reject do |tag|
        tag if options[:skip].include?(tag)
      end
    end

    def set_commits_filter(options)
      options["pull-requests-only"] ? 'Merge pull request' : nil
    end

    def get_commit_messages(previous_tag, current_tag)
      messages = Git::Git.get_filtered_messages(previous_tag,
                                                current_tag,
                                                commit_messages_filter).split("\n")
      # if not filtering merged pull requests only
      # we need to remove the commit sha (first 9 chars in each row)
      messages = messages.map { |msg| msg[10..-1] } unless commit_messages_filter
      messages = categorize_messages(messages, build_categories) if group
      messages = MessageList.new(messages, group)
    end

    def categorize_messages(messages, categories)
      uncategorized = categories.detect { |cat| cat["header"] == "Uncategorized" }
      messages.each do |msg|
        matching_category = categories.detect do |category|
          next unless category["filters"]
          category["filters"].map { |ftr| msg.include?(ftr) }.include?(true)
        end
        if matching_category
          msg = msg.gsub!(filter, matching_category["bullet"])
          matching_category["messages"].push(msg)
        else
          uncategorized["messages"].push("* #{msg}")
        end
      end

      categories
    end

    def build_categories
      categories = YAML.load_file(options[:config])
      categories.each { |category| category["messages"] = [] }
      categories
    end

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
        lines.map { |line| "#{line}\n" }
      end
    end
  end
end
