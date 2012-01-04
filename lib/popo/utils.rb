require 'benchmark'

module Popo
  module Utils
    include Constants

    def self.say(message, subitem = false)
      puts "#{subitem ? "   ->" : "--"} #{message}"
    end

    def self.say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

    def self.in_popo?(root_path)
      if !ENV.include?('popo_path')
        raise "You must be inside popo!"
      end
      true
    end

    def self.has_popo_config?(root_path)
      popo_work_path = File.expand_path(File.join(root_path, POPO_WORK_PATH))

      popo_yml = File.expand_path(File.join(popo_work_path, POPO_YML_FILE))

      if File.exists?(popo_yml)
        popo_config = YAML.load_file(popo_yml)

        if popo_config.is_a?(Hash)
          POPO_CONFIG.update(popo_config)
        else
          raise "#{POPO_WORK_PATH}/#{POPO_YML_FILE} seems to be wrong."
        end

        true
      else
        false
#        raise "#{POPO_YML_FILE} not found."
      end
    end
  end
end

