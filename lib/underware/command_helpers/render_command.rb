
module Underware
  module CommandHelpers
    class RenderCommand < BaseCommand
      private

      def run
        puts namespace.render_file(template_path)
      end

      def namespace
        maybe_namespace = find_namespace(namespace_name)
        return maybe_namespace if maybe_namespace
        # XXX We raise similar errors in other places (`NodeIdentifer`
        # module, `AssetEditor` commands) - maybe we should de-duplicate
        # these for consistency.
        raise InvalidInput, "Could not find #{namespace_type}: #{namespace_name}"
      end

      def find_namespace(namespace_name)
        raise NotImplementedError
      end

      def namespace_type
        class_name_parts.last
      end

      def namespace_name
        args.first if args.length > 1
      end

      def template_path
        path_arg = Pathname.new(args.last)
        path_arg.absolute? ? path_arg : working_directory.join(path_arg).to_s
      end

      def working_directory
        # Working directory that user actually invoked Underware from will be
        # `$OLDPWD` rather than `$PWD`, as we temporarily `cd` in the
        # `underware` shell function in order to ensure a consistent
        # environment (see `etc/profile.d/base.sh`).
        Pathname.new(ENV.fetch('OLDPWD'))
      end
    end
  end
end
