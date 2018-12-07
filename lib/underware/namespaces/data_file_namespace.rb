
require 'hashie'

module Underware
  module Namespaces
    class DataFileNamespace
      delegate :namespace_data_file, to: FilePath

      def method_missing(message, *_args)
        data_file_path = namespace_data_file(message)
        if respond_to?(message)
          Hashie::Mash.load(data_file_path)
        else
          # Normally `method_missing` should call `super` if it doesn't
          # `respond_to?` a message. In this case this is a namespace designed
          # to be used by users writing templates, so give them an informative
          # error message for what they've probably missed instead. This does
          # mean though that we could get a confusing error message if
          # something else goes wrong in this class, so I could eventually come
          # to regret this.
          raise UserUnderwareError,
            "Requested data file doesn't exist: #{data_file_path}"
        end
      end

      def respond_to_missing?(message, _include_all = false)
        data_file_path = namespace_data_file(message)
        File.exist?(data_file_path)
      end
    end
  end
end
