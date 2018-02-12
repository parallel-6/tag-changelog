# tag.rb, part of Create-changelog
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
require 'date'
require_relative 'git'

module Git
  # Represents a Git tag and its annotation.
  class Tag
    # Author commit date of the tag
    attr_reader :date

    # Tag version
    attr_reader :version

    # Gets change information for a specific tagged version.
    #
    # @param [String] tag
    #   Tag for which to instantiate the class.
    def initialize(tag)
      @version = tag
      @date = Date.parse(Git.get_tag_date(tag))
    end
  end
end

# vim: nospell