module Popo
  class Runner
    include Constants

    attr_reader :config
    attr_reader :database, :db_opts
    attr_reader :app_root, :args, :options

    class << self
      def boot(args)
        Utils.colorize
        self.new(args) if has_requirements?
      end

      def has_requirements?
        if ENV.include?('SHELL')
          Popo::Constants.const_set("SHELL", ENV['SHELL'])
        else
          Error.say("SHELL is empty.")
        end

        Popo::Constants::REQUIRED_COMMANDS.each do |b|
          const_fn = "#{b.upcase}_CMD"

          Popo::Constants.const_set(const_fn, get_bin_path(b))

          if Popo::Constants.const_get(const_fn).empty?
            Error.say "#{b} is needed and is not found in PATH!"
          end
        end

        true
      end

      def get_bin_path(bin)
        `which #{bin}`.strip
      end
    end

    def initialize(args)
      @args     = args
      @db_opts  = {}
      @options  = {}
      @app_root = ENV['popo_path'] || Dir.pwd

      if Utils.has_popo_config?(@app_root)
        @options[:target] = POPO_CONFIG['target']
      end

      opt = OptParse.new

      if @args.length >= 1
        opt.optparse.parse!
        @options.merge!(opt.options)

        db_options = {
          :path => File.join(@app_root, POPO_WORK_PATH),
          :target => ENV['CABLING_TARGET'] || @options[:target] || DEFAULT_POPO_TARGET,
          :verbose => @options[:verbose],
          :location => ENV['CABLING_LOCATION'] || @options[:location]
        }

        @db_opts.merge!(db_options)

        # let set these so we can use them in migration files
        Object.const_set("POPO_PATH", @app_root)
        Object.const_set("POPO_USER", @options[:user])
        Object.const_set("POPO_TARGET", @db_opts[:target])
        Object.const_set("POPO_LOCATION", @options[:location])

        mandatory = [:path, :manifest]
        mandatory = mandatory.select { |p| @options[p].nil? }

        if @args.first.eql? 'init' and !mandatory.empty?
          Error.say "Required options: #{mandatory.join(', ')}"
        end

        run
      else
        Utils.say opt.optparse.help
      end
    end

    def run
      if POPO_COMMANDS.include?(@args.first)
        Utils.in_popo?(@app_root)
      end

      cmd = args.shift

      case cmd
      when 'init'
        @config = get_config!

        if @config['manifests'][@options[:manifest]].nil?
          Error.say "\'#{@options[:manifest]}\' does not exist in #{DEFAULT_CONFIG_FILE}!"
        end

        if !File.exist?(File.join(@app_root, @options[:path]))
          @db_opts[:path] = File.join(@app_root, @options[:path], POPO_WORK_PATH)
          get_database

          Init.boot(self).setup
        else
          Error.say "Path \'#{@options[:path]}\' already exists!"
        end
      when 'sync'
        get_database

        Sync.new(self).sync
      when 'rvm'
        get_database

        RVM.new(self).setup
      when 'update'
        manifest_path = File.join(@app_root, POPO_WORK_PATH)

        case POPO_TARGET
        when DEFAULT_POPO_TARGET
          GitUtils.git_update(manifest_path, DEFAULT_POPO_TARGET)
        else
          GitUtils.git_update(manifest_path, 'master')
        end

        get_database
        @database.migrate_database
      when 'migrate'
        get_database
        @database.migrate_database
      when 'info'
        Utils.say `cat #{File.join(@app_root, POPO_WORK_PATH, POPO_YML_FILE)}`
      when 'shell', 'bash'
        sh!
      when 'diff'
        GitUtils.branch_diff(Dir.pwd)
      else
        Error.say "#{cmd} is not a valid command!"
      end
    end

    private

    def sh!
      if Utils.has_popo_config?(@app_root)
        path     = POPO_CONFIG['path']
        target   = POPO_CONFIG['target']
        location = POPO_CONFIG['location']
        shell    = File.basename(SHELL)

        case shell
        when 'bash'
          poporc  = File.expand_path('../../../script/poporc', __FILE__)

          shcmd   = "%s popo_target=%s popo_path=%s \
                    popo_location=%s %s --rcfile %s" \
                    % [ENV_CMD, target, path, location, shell, poporc]
        when 'zsh'
          zdotdir = File.expand_path('../../../script', __FILE__)

          shcmd   = "%s popo_target=%s popo_path=%s \
                    popo_location=%s ZDOTDIR=%s\
                    %s" \
                    % [ENV_CMD, target, path, location, zdotdir, shell]
        else
          Error.say "Shell #{SHELL} is not supported!"
        end

        exec(shcmd)
      end
    end

    def get_database
      @database = Database.new(@app_root, @db_opts)
      @database.boot_database
    end

    def get_config!
      if File.exist?(File.join(ENV['HOME'], ".#{DEFAULT_CONFIG_FILE}"))
        config_file_path = File.join(ENV['HOME'], ".#{DEFAULT_CONFIG_FILE}")
      elsif File.exist?(File.join('/etc', DEFAULT_CONFIG_FILE))
        config_file_path = "/etc/#{DEFAULT_CONFIG_FILE}"
      else
        Error.say "No popo_config.yml found in #{ENV['HOME']} or /etc"
      end

      config_hash = YAML.load_file(config_file_path)
    end
  end
end
