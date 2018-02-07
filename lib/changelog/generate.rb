# A class to manipulate output destination of changelog and to write its contents.
module Changelog
  class Generate
    def self.run(options)
      new(options).run
    end

    def initialize(options = {})
      @options = options
      @destination = open_output_file
      @tags_list = Git::TagList.new(false)
    end

    def run
      tags_list.list.each_cons(2) do |current_tag, previous_tag|
        messages = Git::Git.get_filtered_messages(previous_tag, current_tag, 'Merge pull request').split("\n")
        categorized_messages = categorize_messages(messages, default_categories)
        destination << "## #{current_tag}\n\n"
        categorized_messages.each do |category|
          next unless category[:messages].any?
          destination << "#### #{category[:header]}\n\n"
          category[:messages].each do |line|
            destination << "#{line}\n"
          end
          destination << "\n"
        end
      end
    end

    private

    attr_reader :options, :destination, :tags_list

    def output_file_exists?
      File.exists?(options[:output])
    end

    def open_output_file
      puts "#{options[:output]} doesn't exist in #{options[:dir]}... creating it" unless output_file_exists?
      File.open(options[:output], "w+")
    end

    def categorize_messages(messages, categories)
      messages.each do |msg|
        categories.each do |category|
          next unless category[:filters]
          category[:filters].each do |ftr|
            if msg.include?(ftr)
              msg = msg.gsub!(ftr, category[:bullet])
              category[:messages].push(msg) 
            end
          end
        end
      end
      categories
    end

    def changelog_header
      return "## #{options[:to]}\n\n" if options[:to] == "HEAD"
    end

    def default_categories
      [
        {
          filters: ["[F]", "[ F ]", "[f]", "[ f ]"],
          bullet: "[F]",
          header: "Features",
          messages: []
        },
        {
          filters: ["[C]", "[ C ]", "[c]", "[ c ]"],
          bullet: "[C]",
          header: "Configuration",
          messages: []
        },
        {
          filters: ["[B]", "[ B ]", "[b]", "[ b ]"],
          bullet: "[B]",
          header: "Bug Fixes",
          messages: []
        },
        {
          header: "Uncategorized",
          messages: []
        }
      ]
    end
  end
end
