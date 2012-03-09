module Popo
  class Init
    include Constants

    def self.boot(db, config, options)
      self.new(db, config, options)
    end

    def initialize(db, config, options)
      @options = options
      @db = db
      @manifest = config['manifests'][@options[:manifest]]
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

      clone_path = File.join(@deploy_path, POPO_WORK_PATH)
      GitUtils.git_clone(@manifest['git'], clone_path, @manifest['branch'])

      @db.boot_database
      @db.migrate_database
      repos = @db.get_children("repos")

      repos.each do |r|
        git = @db.get("repos.#{r}.git")
        branch = @db.get("repos.#{r}.branch")
        clone_path = File.join(@deploy_path, r)
        GitUtils.git_clone(git, clone_path, branch)
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

