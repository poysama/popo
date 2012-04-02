require 'benchmark'

module Popo
  module Utils
    include Constants

    def self.colorize
      String.class_eval do
        include Popo::Constants

        constants.grep(/^COLOR/).each do |c|
          color = c.to_s.gsub('COLOR_','').downcase.to_sym

          define_method color do
            if !ENV['popo_no_color']
              "#{Popo::Constants.const_get(c)}#{self}#{COLOR_NONE}"
            else
              self
            end
          end
        end
      end
    end

    def self.say(message, subitem = false)
      puts "#{subitem ? " \->" : "--"} #{message}"
    end

    def self.say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

    def self.git_say(action, message, subitem = false)
      puts "#{subitem ? "\r->" : "\[#{action}\]"} #{message}"
    end

    def self.git_say_with_time(action, message)
      git_say(action, message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end


    def self.in_popo?(root_path)
      if !ENV.include?('popo_path')
        Error.say "You must be inside popo!"
      end

      true
    end

    def self.has_popo_config?(root_path)
      popo_work_path = File.join(root_path, POPO_WORK_PATH)

      popo_yml = File.join(popo_work_path, POPO_YML_FILE)

      if File.exists?(popo_yml)
        popo_config = YAML.load_file(popo_yml)

        if popo_config.is_a?(Hash)
          POPO_CONFIG.update(popo_config)
        else
          Error.say "#{POPO_YML_FILE} seems to be wrong."
        end
      else
        false
      end

      true
    end
  end
end
