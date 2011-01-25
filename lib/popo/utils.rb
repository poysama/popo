module Popo
  COLOR_OK = "\e[33m"
  COLOR_FAIL = "\e[31m"
  NO_COLOR = "\e[0;0m"

  class Utils

    def self.popo_puts(msg, options = {})
      msg = msg.chomp
      sub = options[:sub] || false
      err = options[:err] || false

      unless ENV.include? 'popo_no_color'
        if sub
          err ? popo_fail(msg, options) : puts("   -> #{msg + NO_COLOR}")
        else
          err ? popo_fail(msg, options) : puts("#{COLOR_OK}-- #{msg + NO_COLOR}")
        end
      else
        if sub
          err ? popo_fail("#{msg}", options) : puts("#{msg}")
        else
          err ? popo_fail("-- #{msg}", options) : puts("-- #{msg}")
        end
      end
    end

    def self.popo_fail(msg, options)
      unless ENV.include? 'popo_no_color'
        puts("  -> ERROR: #{COLOR_FAIL + msg + NO_COLOR}")
      else
        puts("  -> ERROR: #{msg}")
      end
      if options[:undo]
        path = File.join(Dir.pwd, options[:path])
        FileUtils.rm_rf(path)
        popo_puts("Something went wrong. Rolling back...",{:sub => true, :err => true})
      end
      exit
    end

    def self.in_popo?(root_path)
      popo_work_path = File.expand_path(File.join(root_path, POPO_WORK_PATH))
      File.exists?(popo_work_path)
    end

    def self.require_relative_work_popo(root_path)
      popo_work_path = File.expand_path(File.join(root_path, POPO_WORK_PATH))

      popo_yml = File.expand_path(File.join(root_path, POPO_WORK_PATH, POPO_YML_FILE))
      if File.exists?(popo_yml)
        popo_config = YAML.load_file(popo_yml)

        if popo_config.is_a?(Hash)
          POPO_CONFIG.update(popo_config)
        else
          popo_puts "#{POPO_WORK_PATH}/#{POPO_YML_FILE} seems to be wrong.", {:sub => true, :err => true}
        end
      else
        popo_puts "#{POPO_YML_FILE} not found.", {:sub => true, :err => true}
      end
    end

    def self.wrap_check(root_path)
      if in_popo?(root_path)
        require_relative_work_popo(root_path)
      else
        popo_puts("You don't seem to be in a popoized directory. Perhaps popo init first? Aborting.", {:sub => true, :err => true})
        exit
      end
    end

  end
end

