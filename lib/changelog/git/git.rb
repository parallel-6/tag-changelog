# git.rb, part of Create-changelog
# Copyright 2015 Daniel Kraus
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# require_relative 'tag_list'

# A static wrapper class for git
module Git
  class Git

    # Determines whether Git is installed
    #
    # @return [bool]
    #   True if Git is installed, false if not.
    #
    def self.is_installed?
      `git --version`
      $? == 0
    end

    # Determines whether the (current) directory is a git repository
    #
    # @param [String] dir
    #   Directory to check; if nil, uses the current directory.
    #
    # @return [bool]
    #   True if the directory is a Git repository, false if not.
    def self.is_git_repository?(dir = nil)
      dir = Dir.pwd if dir.nil?
      system("git status > /dev/null 2>&1")
      $? == 0
    end

    # Determines if the repository in the current directory is empty.
    #
    def self.is_empty_repository?
      `git show HEAD > /dev/null 2>&1`
      $? != 0
    end

    # Retrieves the name of the current branch.
    #
    # @return [String]
    #   Current branch.
    def self.current_branch
      `git branch`.rstrip
    end

    # Launches the text editor that Git uses for commit messages,
    # and passes file as a command line argument to it.
    #
    # @see https://github.com/git/git/blob/master/editor.c
    #   Git's editor.c on GitHub
    #
    # @param [String] file
    #   Filename to pass to the editor.
    #
    # @return [int]
    #   Exit code of the editor process, or false if no editor found.
    #
    def self.launch_editor(file)
      # const char *editor = getenv("GIT_EDITOR");
      editor = ENV['GIT_EDITOR']

      # const char *terminal = getenv("TERM");
      terminal = ENV['TERM'];

      # int terminal_is_dumb = !terminal || !strcmp(terminal, "dumb");
      terminal_is_dumb = !terminal || terminal == 'dumb'

      # if (!editor && editor_program)
      editor = `git config --get core.editor`.rstrip if editor.nil? || editor.empty?

      # if (!editor && !terminal_is_dumb)
      #   editor = getenv("VISUAL");
      editor = ENV['VISUAL'] if (editor.nil? || editor.empty?) && !terminal_is_dumb

      # if (!editor)
      #   editor = getenv("EDITOR");
      editor = ENV['EDITOR'] if (editor.nil? || editor.empty?)

      # if (!editor && terminal_is_dumb)
      #   return NULL;
      # if (!editor)
      #   editor = DEFAULT_EDITOR;
      # Use vi, Git's hard-coded default
      editor = 'vi' if (editor.nil? || editor.empty?) && !terminal_is_dumb

      if editor && !editor.empty?
        system "#{editor} '#{file}'"
        $?
      else
        false
      end
    end

    # Retrieves the first 99 lines of the annotation of a tag.
    #
    def self.get_tag_annotation(tag)
      test_tag tag
      `git tag --sort refname -l -n99 #{tag}`.rstrip
    end

    # Retrieves the author date of a tag
    #
    def self.get_tag_date(tag)
      test_tag tag
      `git log -1 --format=format:%ai #{tag}`
    end

    # Retrieves commit messages and filters them
    # Todo: Armor this against code injection!
    def self.get_filtered_messages(from_commit, to_commit, filter)
      `git log #{from_commit}..#{to_commit} -E --grep='#{filter}' --format=%b`
    end

    # Retrieves one commit message and filters it
    # Todo: Armor this against code injection!
    def self.get_filtered_message(commit, filter)
      `git log #{commit} -E --grep='#{filter}' --format=%b`
    end

    @@tags = nil

    # Ensures lazy loading of the tag list to enable calling code
    # to change the working directory first.
    def self.tags
      @@tags = TagList.new unless @@tags
      @@tags
    end

    # Tests if the given tag exists and fails if it doesn't
    def self.test_tag(tag)
      fail "Invalid tag: #{tag}" unless tags.list.include?(tag)
    end
    private_class_method :test_tag, :tags
  end
end
# vim: nospell
