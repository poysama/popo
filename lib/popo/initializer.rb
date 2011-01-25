module Popo
  class Initializer
    def self.boot(args, options)
      root_path = Dir.pwd
      check_requirements!

      options[:config] = load_config
      options[:root_path] = root_path

      Popo::Runner.run(args, options)
    end

    def self.check_requirements!
      if GIT_CMD.nil? || GIT_CMD.empty?
        Popo::Utils.puts "Can\'t find \`git\` from your path. Perhaps you need to install it?", {:sub => true, :err => true}
      end
    end

    def self.load_config
      if File.exist?("#{ENV['HOME']}/.#{DEFAULT_CONFIG_FILE}")
        config_file_path = "#{ENV['HOME']}/.#{DEFAULT_CONFIG_FILE}"
      else
        config_file_path = "/etc/#{DEFAULT_CONFIG_FILE}"
      end

      if !config_file_path.empty?
        config_hash = YAML.load_file(config_file_path)
      else
        Popo::Utils.puts "Config file not found in #{config_file_path}", {:sub => true, :err => true}
      end
    end
  end
end

