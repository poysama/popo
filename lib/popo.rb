module Popo
  WGET_BIN = `which wget`.strip
  POPORC = 'script/poporc'
  POPO_VERSION = "1.2"
  DEFAULT_CONFIG_FILE = "popo_config.yml"
  POPO_WORK_PATH = ".popo"
  POPO_YML_FILE = "popo.yml"
  POPO_CONFIG = { }
  COMMANDS = %w{ init wipe version }
  GIT_CMD = `which git`.strip
  ENV_CMD = `which env`.strip
  BASH_CMD = `which bash`.strip
  POPO_LIB_ROOT = File.join(File.dirname(__FILE__), 'popo')

  autoload :Initializer, (File.join(POPO_LIB_ROOT, 'initializer'))
  autoload :Runner, (File.join(POPO_LIB_ROOT, 'runner'))
  autoload :Utils, (File.join(POPO_LIB_ROOT, 'utils'))
  autoload :Deployer, (File.join(POPO_LIB_ROOT, 'deployer'))

  class Popoized

    def self.info(root_path)
      info = {
        "Work Path" => root_path,
        "Target" => POPO_CONFIG["target"]
      }

      info.each do |k,v|
        Popo::Utils.popo_puts "#{k}: #{v}"
      end
    end

    def self.status(root_path)
      puts "Gathering status info, please be patient, this can take a while on a pathetic machine..."
      $stdout.flush
    end

    def self.bash(root_path)
      if BASH_CMD.nil? || BASH_CMD.empty?
        Popo::Utils.popo_puts("FAIL bash is nowhere to be found", {:sub => true, :err => true})
      end

      if ENV_CMD.nil? || ENV_CMD.empty?
        Popo::Utils.popo_puts("FAIL env is nowhere to be found", {:sub => true, :err => true})
      end

      target = POPO_CONFIG['target']
      bashcmd = "#{ENV_CMD} popo_target=#{target} popo_path=#{root_path} #{BASH_CMD} --rcfile #{File.join(root_path, POPO_WORK_PATH, POPORC)}"
      exec(bashcmd)
    end

    def self.rvm(root_path, argv)
      if ENV_CMD.nil? || ENV_CMD.empty?
        Popo::Utils.popo_puts("FAIL env is nowhere to be found", {:sub => true, :err => true})
      end

      target = POPO_CONFIG['target']
      poporc_path = File.join(root_path, POPO_WORK_PATH, POPORC)

      if argv.size > 1
        bashcmd = "#{ENV_CMD} popo_target=#{target} popo_path=#{root_path} #{poporc_path} #{argv[1..-1].join(' ')}"
      else
        bashcmd = "#{ENV_CMD} popo_target=#{target} popo_path=#{root_path} #{poporc_path}"
      end
      exec(bashcmd)
    end

    def self.get_manifest(root_path, options)
      if WGET_BIN.nil? || WGET_BIN.empty?
        Popo::Utils.popo_puts("FAIL wget is nowhere to be found", {:sub => true, :err => true})
      end

      config = options[:config]
      target = options[:target] || config['popo']['default_target']
      manifest = [config['manifest']['source'], options[:manifest]].join('/')
      user = options[:user] || ENV['USER']
      path = options[:path] ? File.join(root_path, options[:path]) : root_path

      if File.exist?(File.join(ENV['HOME'], '.popo_password')) and File.size?(File.join(ENV['HOME'], '.popo_password')) != nil
        cmd = "#{WGET_BIN} -nv #{manifest} -r --level=1 --user=#{user}"
        cmd += " --http-password \`cat #{ENV['HOME']}/.popo_password\`"
        cmd += " -nd -P #{path} -A *.yml"
      else
        cmd = "#{WGET_BIN} -nv #{manifest} -r --level=1 --user=#{user}"
        cmd += " --ask-password -nd -P #{path} -A *.yml"
      end

      Popo::Utils.popo_puts("Downloading manifest file...")

      system cmd
      move_yml_files(path)

      Popo::Utils.popo_puts("Configure OK!")
    end

    def self.move_yml_files(path)
      Dir.entries(path).each do |file|
        if file.match(/.yml$/)
          chopped_file = file.sub('-defaults', '')
          FileUtils.mv(File.join(path, file), File.join(path, POPO_WORK_PATH, file))
          create_local(path, chopped_file)
          merge_config(path, file)
          FileUtils.rm(File.join(path, POPO_WORK_PATH, file))
        else
          error_msg = "Manifest file download failed."
          echo_opts = {:sub => true, :err => true, :undo => true, :path => path}
          Popo::Utils.popo_puts(error_msg, echo_opts) if $? != 0
        end
      end
    end

    def self.reconfigure(root_path, options)
      get_manifest(root_path, options)
      replace_popo_user(root_path, options)
    end

    def self.replace_popo_user(root_path, options)
      target_path = options[:path] || root_path
      user = options[:user] || ENV['USER']

      popo_yml = File.read(File.join(target_path, POPO_WORK_PATH, 'popo.yml'))

      popo_yml.gsub!('%user%', user) # for gerrit user specific repos

      File.open(File.join(target_path, POPO_WORK_PATH, 'popo.yml'), 'w') {|f| f.write(popo_yml) }
    end

    def self.create_local(path, file)
      FileUtils.touch(File.join(path, POPO_WORK_PATH, "#{file.chomp('.yml')}-local.yml"))
    end

    def self.merge_config(path, file)
      yml_msg = "# Generated #{file}.yml #{Time.now}.\n"
      yml_msg += "# This file is auto generated and must not be edited.\n"
      yml_msg += "# All local edits are in respective -local files\n"
      yml_msg += "# and must be reconfigured to take effect.\n"

      work_path = File.join(path, POPO_WORK_PATH)

      local_file = YAML.load_file(File.join(work_path, "#{file.chomp('-defaults.yml')}-local.yml"))
      default_file = YAML.load_file(File.join(work_path, file))

      if local_file.is_a?(Hash)
        default_file.deep_merge!(local_file)
      end

      dump_file = YAML.dump(default_file)
      dump_file.gsub!(/---/, yml_msg)

      File.open(File.join(work_path, "#{file.chomp('-defaults.yml')}.yml"), 'w') {|f| f.write(dump_file) }
    end
  end
end

