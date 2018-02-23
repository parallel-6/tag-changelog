# TagList, part of Create-changelog
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

# Builds a list of tags in the current git repository.
# The tags are enclosed by the sha1 of the first commit
# and optionally "HEAD" to allow traversing the list
# with each_con to obtain start and end points of
# developmental epochs.
module Git
  class TagList
    # Returns an array of tag names surrounded by HEAD
    # at the top and the sha1 of the first commit at the
    # bottom.
    attr_reader :list

    # Instantiates the tag list.
    #
    # @param [bool] include_head
    #   Indicates whether or not to include the most recent changes.
    #
    def initialize(include_head = true)
      @include_head = include_head
      @list = build_list
    end

    # Returns the most recent tag in the git repository,
    # or the sha1 of the initial commit if there is no tag.
    #
    # @return [String]
    #
    def latest_tag
      # Index 0 is HEAD
      # Index 1 is most recent tag or first commit
      @list[1]
    end

    private

    # Returns the sha1 of the initial commit.
    # In fact, this function returns all parentless commits
    # of the repository. Usually there should be not more than
    # one such commit.
    # See http://stackoverflow.com/a/1007545/270712
    #
    def get_initial_commit
      `git rev-list --max-parents=0 HEAD`.chomp
    end

    # Builds a list of Git tags and encloses it with HEAD and the
    # Sha-1 of the initial commit.
    #
    # @return [Array]
    #   Array of tags, surrounded by HEAD and the Sha-1 of the initial commit.
    def build_list
      tags = []
      tags <<  get_initial_commit
      tags += `git tag --sort v:refname`.split("\n").map { |s| s.rstrip }
      tags << "HEAD" if @include_head
      tags.reverse
    end
  end
end
# vim: nospell
