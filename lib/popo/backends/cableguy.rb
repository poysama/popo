module Popo
  module Backends
    class Cableguy
      def self.invoke(app_root, options)
        self.new(app_root, options)
      end

      def initialize(app_root, options)
        @cabler = Palmade::Cableguy::Cabler.new(app_root, options)
      end

      def boot_database
        @cabler.boot
      end

      def migrate_database
        @cabler.migrate
      end

      def get(key, group = 'manifest')
        @cabler.db.get(key, group)
      end

      def get_children(key, group = 'manifest')
        @cabler.db.get_children(key, group)
      end

      def has_key?(key, group = 'manifest')
        @cabler.db.has_key?(key, group)
      end

      def migration_constants(options)
        Object.const_set("POPO_PATH", @root)
        Object.const_set("POPO_USER", options[:user])
        Object.const_set("POPO_TARGET", options[:target])
      end

    end
  end
end
