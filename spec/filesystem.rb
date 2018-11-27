# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Underware.
#
# Alces Underware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Underware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Underware, please visit:
# https://github.com/alces-software/underware
#==============================================================================

require 'fakefs/safe'
require 'underware/constants'
require 'minimal_repo'
require 'underware/validation/configure'

# XXX Reduce the hardcoded paths once sorted out Config/Constants situation.

class FileSystem
  # Only interface to `FileSystem` is to call `FileSystem.setup` and then later
  # `test` on the resulting object, or to call `FileSystem.test` directly.
  private_class_method :new

  module SetupMethods
    # This module contains all methods to be called on a FileSystem to set up
    # the underlying FakeFS. All methods are appropriately delegated here, so
    # these can be called on a `FileSystemConfigurator` instance and will then
    # be correctly invoked when `FileSystem.test` is run with that instance.
    # This module is necessary as if any of the original methods were run
    # directly outside of a `test` block then the real file system would be
    # used.

    delegate :mkdir_p, :touch, :rm_rf, to: FileUtils
    delegate :write, to: File
    delegate :dump, to: Underware::Data
    delegate :clone, to: FakeFS::FileSystem

    def activate_plugin(plugin_name)
      Underware::Plugins.activate!(plugin_name)
    end

    # Create an empty file given any path, by creating every needed parent
    # directory and then the file itself.
    def create(file_path)
      dir_path = File.dirname(file_path)
      FileUtils.mkdir_p(dir_path)
      FileUtils.touch(file_path)
    end

    # Perform arbitrary other FileSystem setup.
    # TODO Maybe everything/more things should be changed to just do this,
    # rather than continuing to add new methods here every time we want to
    # create a file in a new way?
    def setup
      yield
    end
  end
  include SetupMethods

  def self.root_setup
    FakeFS.without do
      yield FileSystem.root_file_system_config
      FileSystem.test {} # Applies the changes
    end
  end

  def self.root_file_system_config(reset: false)
    @root_file_system_config = nil if reset
    @root_file_system_config ||= FileSystemConfigurator.new
  end

  # Perform optional configuration of the `FileSystem` prior to a `test`. The
  # yielded and returned `FileSystemConfigurator` caches any unknown method
  # calls it receives. When `test` is later called on it, it runs
  # `FileSystem#test` in the usual way but any cached `FileSystem` method calls
  # will be executed prior to yielding the setup `FileSystem` to the
  # user-passed block.
  #
  # Since there is a single global `FakeFS`, this has an advantage over running
  # method calls to set this up directly as it prevents it from being in an
  # inconsistent state, as well as ensuring the `FakeFS` is used only while the
  # `FakeFS do` block is executing in `test`.
  #
  # XXX This has the disadvantage that for calls which fail the exception is
  # not thrown from where the actual failing call is made; it could be worth
  # actually running the methods to check this, and then replaying them afresh
  # when `test` is run.
  def self.setup(&block)
    FileSystemConfigurator.new.tap do |configurator|
      yield configurator if block
    end
  end

  def self.test(configurator = FileSystem.root_file_system_config)
    # Ensure the FakeFS is in a fresh state. XXX needed?
    FakeFS.deactivate!
    FakeFS.clear!

    FakeFS do
      filesystem = new
      filesystem.create_initial_directory_hierarchy
      filesystem.clone_in_templates_dir

      configurator.configure_filesystem(filesystem)

      yield filesystem
    end
  end

  # This should construct the most minimal possible valid Underware repo, at
  # the default repo path.
  def with_minimal_repo
    MinimalRepo.create_at('/var/lib/underware/repo')
  end

  def with_fixtures(fixtures_dir, at:)
    path = fixtures_path(fixtures_dir)
    clone(path, at)
  end

  def with_validation_error_file
    clone(Underware::FilePath.dry_validation_errors)
  end

  def with_repo_fixtures(repo_fixtures_dir)
    # Create the minimal parts of a Underware repo, these can then be
    # overridden by the specified fixtures.
    with_minimal_repo

    with_fixtures(repo_fixtures_dir, at: '/var/lib/underware/repo')
  end

  def with_answer_fixtures(answer_fixtures_dir)
    with_fixtures(answer_fixtures_dir, at: '/var/lib/underware/answers')
  end

  def with_genders_fixtures(genders_file = 'genders/default')
    with_fixtures(genders_file, at: Underware::Constants::GENDERS_PATH)
  end

  def with_group_cache_fixture(group_cache_file)
    with_fixtures(
      group_cache_file,
      at: Underware::Constants::GROUP_CACHE_PATH
    )
  end

  def with_clone_fixture(fixture_file)
    with_fixtures(fixture_file, at: fixtures_path(fixture_file))
  end

  def with_asset_types
    asset_types_dir_path = File.dirname(Underware::FilePath.asset_type(''))
    clone(asset_types_dir_path, asset_types_dir_path)
  end

  # Create same directory hierarchy that would be created by an Underware
  # install (without directories unneeded for any tests to pass).
  def create_initial_directory_hierarchy
    [
      '/tmp',
      '/var/lib/underware/rendered/system',
      '/var/lib/underware/cache/templates',
      '/var/lib/underware/repo',
      '/var/lib/underware/answers/groups',
      '/var/lib/underware/answers/nodes',
      '/var/lib/underware/assets',
      '/var/lib/underware/data',
      '/var/log/underware',
    ].each do |path|
      FileUtils.mkdir_p(path)
    end
  end

  def clone_in_templates_dir
    templates_dir = Underware::FilePath.templates_dir
    clone(templates_dir, templates_dir)
  end

  # Print every directory and file loaded in the FakeFS.
  delegate :debug, to: FileSystem
  def self.debug!
    begin
      # This can fail oddly if nothing matches (see
      # https://github.com/fakefs/fakefs/issues/371), hence the `rescue` with a
      # simpler glob.
      matches = Dir['**/*']
    rescue NoMethodError
      matches = Dir['*']
    end

    matches.each do |path|
      identifier = File.file?(path) ? 'f' : 'd'
      STDERR.puts "#{identifier}: #{path}"
    end
  end

  private

  def fixtures_path(relative_fixtures_path)
    File.join(FIXTURES_PATH, relative_fixtures_path)
  end

  class FileSystemConfigurator
    def initialize
      @method_calls = []
    end

    def method_missing(name, *args, &block)
      method_calls << MethodCall.new(name, args, block)
    end

    def configure_filesystem(filesystem)
      method_calls.each do |method|
        filesystem.send(method.name, *method.args, &method.block)
      end
    end

    def test(&block)
      FileSystem.test(self, &block)
    end

    private

    attr_reader :method_calls
  end

  MethodCall = Struct.new(:name, :args, :block)
end
