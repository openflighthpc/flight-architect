# frozen_string_literal: true

require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/string/filters'

require 'data'
require 'file_path'
require 'recursive-open-struct'

module Metalware
  class Staging
    def self.update
      staging = new
      yield staging if block_given?
    ensure
      staging&.save
    end

    def self.template
      update do |staging|
        templater = Templater.new(staging)
        if block_given?
          yield templater
        else
          templater
        end
      end
    end

    def self.manifest
      new.manifest
    end

    private_class_method :new

    def save
      Data.dump(FilePath.staging_manifest, manifest.to_h)
    end

    def manifest
      @manifest ||= begin
        Data.load(FilePath.staging_manifest).tap do |x|
          x.merge! blank_manifest if x.empty?
          # Converts the file paths to strings
          x[:files] = x[:files].map { |key, data| [key.to_s, data] }.to_h
        end
      end
    end

    def push_file(sync, content, **options)
      staging = FilePath.staging(sync)
      FileUtils.mkdir_p(File.dirname(staging))
      File.write(staging, content)
      manifest[:files][sync] = default_push_options.merge(options)
    end

    private

    def default_push_options
      {
        managed: false,
        validator: nil,
      }
    end

    def blank_manifest
      { files: {}, services: [] }
    end

    class Templater
      def initialize(staging)
        @staging = staging
      end

      def render(
        namespace,
        template,
        sync_location,
        dynamic: {},
        **staging_options
      )
        rendered = namespace.render_file(template, **dynamic)
        staging.push_file(sync_location, rendered, **staging_options)
      end

      private

      attr_reader :staging
    end
  end
end
