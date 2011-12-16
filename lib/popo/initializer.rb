module Popo
  class Initializer
    include Constants

    def self.boot(config, options)
      self.new(config, options)
    end

    def initialize(config, options)
      @repos = {}

      config['repos'].each do |k, v|
        @repos[k] = v
      end

      @options = options
      @default_target = @options[:target] || 'development'
      @deploy_path = File.absolute_path(@options[:path])
      @location = @options[:location] || nil
    end

    def print_variables
      instance_variables.each do |i|
        say instance_variable_get(i)
      end
    end

    def setup
      print_variables if @options[:verbose]

      @repos.each do |k, v|
        basename = File.basename(v['git'])

        if k == POPO_WORK_PATH.delete('.')
          clone_path = File.join(@deploy_path, POPO_WORK_PATH)
        else
          clone_path = File.join(@deploy_path, basename)
        end

        GitUtils.git_clone(v['git'], clone_path, v['branch'])
      end

      write_config
    end

    def write_config
      popo = {}
      popo['target'] = @default_target
      popo['path'] = @deploy_path
      popo['location'] = @location if !@location.nil?

      yml_path = File.join(@deploy_path, POPO_WORK_PATH, POPO_YML_FILE)

      File.open(yml_path, "w") do |f|
        YAML.dump(popo, f)
      end
    end
  end
end

