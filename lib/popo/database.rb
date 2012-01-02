module Popo
  class Database
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
  end
end
