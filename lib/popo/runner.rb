module Popo
  class Runner
    include Constants

    def self.boot(args)
      check_requirements

      Popo::Constants.const_set("SHELL", ENV['SHELL'])

      if SHELL.empty?
        Error.say("SHELL is empty.")
      end

      self.new(args)
    end

    def self.check_requirements
      bins = ['env', 'git' ]

      bins.each do |b|
        const_fn = "#{b.upcase}_CMD"

        Popo::Constants.const_set(const_fn, get_bin_path(b))

        if Popo::Constants.const_get(const_fn).empty?
          Error.say "#{b} is needed and is not found in PATH!"
        end
      end
    end

    def self.get_bin_path(bin)
      `which #{bin}`.strip
    end

    def initialize(args)
      @db_opts           = {}
      @options           = {}
      @app_root          = ENV['popo_path'] || Dir.pwd
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
        @db_opts[:verbose]  = @options[:verbose]
        @db_opts[:location] = ENV['CABLING_LOCATION'] || @options[:location]

        # set manifest usable constants
        Object.const_set("POPO_PATH", @app_root)
        Object.const_set("POPO_USER", @options[:user])
        Object.const_set("POPO_TARGET", @db_opts[:target])
        Object.const_set("POPO_LOCATION", @options[:location])

        mandatory = [:path, :manifest]
        mandatory = mandatory.select { |p| @options[p].nil? }

        if args.first == 'init' and !mandatory.empty?
          Error.say "Missing options: #{mandatory.join(', ')}"
        end

        self.run(args)
      end
    end

    def run(args)
      if POPO_COMMANDS.include?(args.first)
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
          db = get_database

          Init.boot(db, config, @options).setup
        else
          Error.say "Path \'#{@options[:path]}\' already exists!"
        end
      when 'sync'
        db = get_database

        Sync.new(db, @app_root, args).sync
      when 'rvm'
        db = get_database

        RVM.new(db, @app_root, args).setup
      when 'migrate'
        get_database.migrate_database
      when 'status'
        Utils.say `cat #{File.join(@app_root, POPO_WORK_PATH, POPO_YML_FILE)}`
      when 'shell', 'bash'
        sh!
      when 'diff'
        GitUtils.branch_diff(Dir.pwd)
      else
        Error.say "#{cmd} is not a valid command!"
      end
    end

    protected

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
      database = Database.new(@app_root, @db_opts)
      database.boot_database

      database
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
