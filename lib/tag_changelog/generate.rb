# A class to manipulate output destination of changelog and to write its contents.
module TagChangelog
  class Generate
    def self.run(project_config, options)
      new(project_config, options).run
    end

    def initialize(project_config = {}, options = {})
      @project_config = project_config
      @options = options
      @config = build_configuration
      @output = open_output_file
      @tags_list = build_tags_list
      @filter = Regexp.new(config["filter"], true)
      @commit_messages_filter = set_commits_filter
      @group = config["group"]
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
                :group,
                :config

    def build_configuration
      default_config
        .merge(@project_config)
        .merge(@options.delete_if { |_, v| v.nil? })
    end

    def default_config
      YAML.load_file(@project_config["config_file"])
    end

    def output_file_exists?
      File.exists?(config["output"])
    end

    def open_output_file
      puts "#{config['output']} doesn't exist in #{options[:dir]}... creating it" unless output_file_exists?
      File.open(config["output"], "w+")
    end

    def build_tags_list
      Git::TagList.new(config["head"]).list.reject do |tag|
        tag if config["skip"].include?(tag)
      end
    end

    def set_commits_filter
      config["pull-requests-only"] ? 'Merge pull request' : nil
    end

    def get_commit_messages(previous_tag, current_tag)
      messages = Git::Git.get_filtered_messages(previous_tag,
                                                current_tag,
                                                commit_messages_filter).split("\n")
      # if not filtering merged pull requests only
      # we need to remove the commit sha1
      messages = messages.map { |msg| msg.split(" ")[1..-1].join(" ") } unless commit_messages_filter
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
          uncategorized["messages"].push("#{msg}")
        end
      end

      categories
    end

    def build_categories
      categories = config["categories"].dup
      categories.push({ "bullet" => "[U]", "header" => "Uncategorized" })
      categories.each { |category| category["messages"] = [] }
      categories
    end
  end
end
