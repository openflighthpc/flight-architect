
# frozen_string_literal: true

module Underware
  class ManagedFile
    MANAGED_START_MARKER = 'UNDERWARE_START'
    MANAGED_END_MARKER = 'UNDERWARE_END'
    MANAGED_COMMENT_TEXT = <<-EOF.squish
      This section of this file is managed by Alces Underware. Any changes made
      to this file between the #{MANAGED_START_MARKER} and
      #{MANAGED_END_MARKER} markers may be lost; you should make any changes
      you want to persist outside of this section or to the template directly.
    EOF

    class << self
      def content(*args)
        NewContent.new(*args).create
      end

      private

      class NewContent
        def initialize(managed_file, rendered_content, comment_char: '#')
          @managed_file = managed_file
          @rendered_content = rendered_content
          @comment_char = comment_char
        end

        def create
          pre, post = split_on_managed_section(current_file_contents)
          new_managed_section = managed_section(rendered_content.strip)
          new_content = [pre, new_managed_section, post].join
          new_content + (new_content.end_with?("\n") ? '' : "\n")
        end

        private

        attr_reader \
          :managed_file,
          :rendered_content,
          :comment_char

        def current_file_contents
          File.exist?(managed_file) ? File.read(managed_file) : ''
        end

        def split_on_managed_section(file_contents)
          if file_contents.include? managed_start
            pre, rest = file_contents.split(managed_start)
            _, post = rest.split(managed_end)
            [pre, post]
          else
            [file_contents, nil]
          end
        end

        def managed_section(rendered_template)
          [
            managed_start,
            managed_comment,
            rendered_template,
            managed_end,
          ].join("\n")
        end

        def managed_start
          comment_wrapped(MANAGED_START_MARKER)
        end

        def managed_end
          comment_wrapped(MANAGED_END_MARKER)
        end

        def comment_wrapped(marker)
          comment_chars = comment_char * 10
          [comment_chars, marker, comment_chars].join(' ')
        end

        def managed_comment
          Utils.commentify(MANAGED_COMMENT_TEXT, comment_char: comment_char)
        end
      end
    end
  end
end
