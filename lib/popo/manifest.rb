require 'erb'

module Popo
  class Manifest
    include Constants

    attr_reader :options, :name, :path

    def initialize(base, name, options)
      @base = base
      @options = options
      @name = name
      @config = {}
    end

    def path
      @path ||= File.join(@base.work_path, '.manifest')
    end

    def download
      `curl -s #{@options[:source]}`
    end

    def load_config(data)
      @config = Config.boot(data)
    end

    def source
      "%s@%s:%s" % [@config['user'], @config['host'], @config[@name]]
    end

    def setup
      Helpers::Git.clone(source, @config['branch'], deploy_path)
    end

    def deploy_path
      path
    end

    def clean
      FileUtils.rm_rf(deploy_path)
    end

    def log
      @base.logger
    end

    def migrate(options)
      db = Backends::Cableguy.invoke(options[:path], options)
      db.migration_constants(options)
      db.boot_database
      db.migrate_database
    end

    def write_config
      config = { 'target' => @base.target,
                  'path' => @base.work_path }

      file = File.join(deploy_path, POPO_YML_FILE)

      File.open(file, "w") do |f|
        YAML.dump(config, f)
      end
    end
  end
end

