# frozen_string_literal: true

require 'data'
require 'file_path'
require 'recursive-open-struct'
require 'templater'

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
  end
end
