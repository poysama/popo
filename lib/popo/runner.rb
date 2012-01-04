module Popo
  class Runner
    include Constants

    def self.boot(args)
      Popo::Constants.const_set("BASH_CMD", `which bash`.strip)
      Popo::Constants.const_set("ENV_CMD", `which env`.strip)
      Popo::Constants.const_set("GIT_CMD", `which git`.strip)

      self.new(args)
    end

    def initialize(args)
      @popo_path = ENV['popo_path'] || Dir.pwd
      Object.const_set("POPO_PATH", @popo_path)

      @options = {}
      @cabler_options = {}
      @options[:verbose] = false
      @options[:target] = 'development'

      if Utils.has_popo_config?(@popo_path)
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

      if args.length == 0
        Utils.say optparse.help
      else
        Object.const_set("POPO_TARGET", @options[:target])
        Object.const_set("POPO_LOCATION", @options[:location])
        Object.const_set("POPO_USER", @options[:user])

        @cabler_options = { :path  => File.join(@popo_path, POPO_WORK_PATH),
                            :target   => ENV['CABLING_TARGET'] || @options[:target] || 'development',
                            :location => ENV['CABLING_LOCATION'] || @options[:location],
                            :verbose  => @options[:verbose]
                          }
        self.run(args)
      end
    end

    def run(args)
      case args.shift
      when 'init'
        config = get_config!

        if !@options[:manifest].nil?
          if config['manifests'][@options[:manifest]].nil?
            raise "manifest #{@options[:manifest]} does not exist in #{DEFAULT_CONFIG_FILE}!"
          end
        else
          raise "manifest (-m) option needed!"
        end

        if !@options[:path].nil?
          if !File.exist?(File.join(@popo_path, @options[:path]))
            @cabler_options[:path] = File.join(@popo_path, @options[:path], POPO_WORK_PATH)
            db = Database.new(@popo_path, @cabler_options)
            Initializer.boot(config, @options, db).setup
          else
            raise "Path already exists!"
          end
        else
          raise "path (-p) option needed!"
        end
      when 'sync'
        if Utils.in_popo?(@popo_path)
          db = Database.new(@popo_path, @cabler_options)
          db.boot_database

          Sync.new(@popo_path, args, db).gather
        end
      when 'rvminstall'
        if Utils.in_popo?(@popo_path)
          db = Database.new(@popo_path, @cabler_options)
          db.boot_database
          RVM.new(@popo_path, args, db).setup
        end
      when 'migrate'
        if Utils.in_popo?(@popo_path)
          db = Database.new(@popo_path, @cabler_options)
          db.boot_database
          db.migrate_database
        end
      when 'status'
        Utils.say `cat #{File.join(@popo_path, POPO_WORK_PATH, POPO_YML_FILE)}`
      when 'upload'
        puts "Pushing!"
      when 'bash'
        bash!
      else
        puts "I don't know what to do."
      end
    end

    def bash!
      if Utils.has_popo_config?(Dir.pwd)

        poporc_path = File.join(Dir.pwd, POPO_WORK_PATH, POPORC)
        target = POPO_CONFIG['target']
        path = POPO_CONFIG['path']
        location = POPO_CONFIG['location']

        bashcmd = "%s popo_target=%s popo_path=%s \
                  popo_location=%s %s --rcfile %s" \
                  % [ENV_CMD, target, path, location, BASH_CMD, poporc_path]

        exec(bashcmd)
      else
        raise "#{POPO_YML_FILE} not found or it may be wrong!"
      end
    end

    def get_config!
      if File.exist?(File.join(ENV['HOME'], ".#{DEFAULT_CONFIG_FILE}"))
        config_file_path = File.join(ENV['HOME'], ".#{DEFAULT_CONFIG_FILE}")
      elsif File.exist?(File.join('/etc', DEFAULT_CONFIG_FILE))
        config_file_path = "/etc/#{DEFAULT_CONFIG_FILE}"
      else
        raise "No popo_config.yml found in #{ENV['HOME']} or /etc"
      end

      config_hash = YAML.load_file(config_file_path)
    end
  end
end
