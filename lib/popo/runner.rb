module Popo
  class Runner
    include Constants

    def self.boot(args)
      Popo::Constants.const_set("BASH_CMD", `which bash 2>/dev/null`.strip)
      Popo::Constants.const_set("ZSH_CMD", `which zsh 2>/dev/null`.strip)
      Popo::Constants.const_set("ENV_CMD", `which env 2>/dev/null`.strip)
      Popo::Constants.const_set("GIT_CMD", `which git 2>/dev/null`.strip)

      self.new(args)
    end

    def initialize(args)
      @db_opts           = {}
      @options           = {}
      @app_root         = ENV['popo_path'] || Dir.pwd
      @options[:verbose] = false

      if Utils.has_popo_config?(@app_root)
        @options[:target] = POPO_CONFIG['target']
      end

      optparse = OptionParser.new do |opts|
        opts.banner = "Popo tool."
        opts.separator "Options:"

        opts.on('-p', '--path PATH', 'Target path') do |path|
          @options[:path] = path
        end

        opts.on('-t', '--target TARGET', 'Deployment target') do |target|
          @options[:target] = target
        end

        opts.on('-u', '--user USER', 'Username') do |user|
          @options[:user] = user
        end

        opts.on('-m', '--manifest MANIFEST', 'Manifest') do |manifest|
          @options[:manifest] = manifest
        end

        opts.on('-l', '--location LOCATION', 'Location') do |location|
          @options[:location] = location
        end

        opts.on('-v', '--verbose', 'Verbose') do
          @options[:verbose] = true
        end

        opts.on('-V', '--version', 'Version') do
          puts Popo::VERSION
          exit
        end

        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end
      end

      optparse.parse!

      if args.length < 1
        Utils.say optparse.help
      else
        @db_opts[:path]     = File.join(@app_root, POPO_WORK_PATH)
        @db_opts[:target]   = ENV['CABLING_TARGET'] || @options[:target] || DEFAULT_POPO_TARGET
        @db_opts[:location] = ENV['CABLING_LOCATION'] || @options[:location]
        @db_opts[:verbose]  = @options[:verbose]

        # set manifest usable constants
        Object.const_set("POPO_PATH", @app_root)
        Object.const_set("POPO_TARGET", @db_opts[:target])
        Object.const_set("POPO_LOCATION", @options[:location])
        Object.const_set("POPO_USER", @options[:user])


        mandatory = [:path, :manifest]
        mandatory = mandatory.select { |p| @options[p].nil? }

        if args.first == 'init' and !mandatory.empty?
          Error.say "Missing options: #{mandatory.join(', ')}"
        end

        self.run(args)
      end
    end

    def run(args)
      if POPO_COMMANDS.include?(args)
        Utils.in_popo?(@app_root)
      end

      cmd = args.shift

      case cmd
      when 'init'
        config = get_config!

        if config['manifests'][@options[:manifest]].nil?
          Error.say "\'#{@options[:manifest]}\' does not exist in #{DEFAULT_CONFIG_FILE}!"
        end

        if !File.exist?(File.join(@app_root, @options[:path]))
          @db_opts[:path] = File.join(@app_root, @options[:path], POPO_WORK_PATH)
          db = Database.new(@app_root, @db_opts)

          Initializer.boot(config, @options, db).setup
        else
          Error.say "Path already exists!"
        end
      when 'sync'
        db = Database.new(@app_root, @db_opts)
        db.boot_database

        Sync.new(@app_root, args, db).sync
      when 'rvm'
        db = Database.new(@app_root, @db_opts)
        db.boot_database

        RVM.new(@app_root, args, db).setup
      when 'migrate'
        db = Database.new(@app_root, @db_opts)
        db.boot_database
        db.migrate_database
      when 'status'
        Utils.say `cat #{File.join(@app_root, POPO_WORK_PATH, POPO_YML_FILE)}`
      when 'bash'
        sh!(cmd)
      when 'zsh'
        sh!(cmd)
      when 'diff'
        GitUtils.branch_diff(Dir.pwd)
      else
        Error.say "#{args} not a valid command!"
      end
    end

    def sh!(shell)
      if Utils.has_popo_config?(@app_root)
        path     = POPO_CONFIG['path']
        target   = POPO_CONFIG['target']
        location = POPO_CONFIG['location']

        if shell == 'bash'
          poporc  = File.expand_path('../../../script/poporc', __FILE__)

          shcmd   = "%s popo_target=%s popo_path=%s \
                    popo_location=%s %s --rcfile %s" \
                    % [ENV_CMD, target, path, location, BASH_CMD, poporc]
        else
          zdotdir = File.expand_path('../../../script', __FILE__)

          shcmd   = "%s popo_target=%s popo_path=%s \
                    popo_location=%s ZDOTDIR=%s\
                    %s" \
                    % [ENV_CMD, target, path, location, zdotdir, ZSH_CMD]
        end

        exec(shcmd)
      end
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
