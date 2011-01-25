module Popo
  class Deployer

    def self.init(args, options)
      root_path = options[:root_path]
      @target_path = options[:path]
      @popo_target = options[:target] || options[:config]['popo']['default_target']
      config = options[:config]

      config['repo'].each { |k, v| clone(v) }

      premade_directories(root_path, config['popo']['tree'])

      system("echo \'target: #{@popo_target}\' > #{File.join(@target_path, POPO_WORK_PATH, POPO_YML_FILE)}")

      Popo::Utils.require_relative_work_popo(@target_path)
      Popo::Popoized.reconfigure(root_path, options)

      configure_envy
      rvm_install(config)
      set_default_rvm(config)
    end

    def self.clone(what)
      if what.include? 'popo.git'
        custom_path = '.' + what.chomp('.git').split('/').last
      else
        custom_path =  what.chomp('.git').split('/').last
      end

      target_path = File.join(@target_path, custom_path)

      Popo::Utils.popo_puts("Deploying #{custom_path}")

      unless File.exist? target_path
        cmd = "#{GIT_CMD} clone #{what} #{target_path}"
      else
        Popo::Utils.popo_puts("Path #{[@target_path, custom_path].join('/')} exist!", { :sub => true, :err => true })
      end

      system cmd unless cmd.nil?
    end

    def self.configure_envy
      Popo::Utils.popo_puts("Preconfiguring envy...")
      envy_yml = File.read(File.join(@target_path, POPO_WORK_PATH, 'lib', 'templates', 'envy.yml'))
      envy_yml.gsub!('%popo_path%', File.join(Dir.pwd, @target_path))
      envy_yml.gsub!('%popo_target%',@popo_target)
      File.open(File.join(@target_path, POPO_WORK_PATH, 'config/envy.yml'), 'w') {|f| f.write(envy_yml) }
      Popo::Utils.popo_puts("Done!")
    end

    def self.rvm_install(config)
      Popo::Utils.popo_puts("Deploying rvm rubies...")
      envy = get_envy_path
      rubies = config['rvm']['rubies']

      rubies.each do |r|
        Popo::Utils.popo_puts("Deploying #{r}")
        cmd = "#{envy} rvm install #{r}"
        system cmd
      end
    end

    def self.set_default_rvm(config)
      default_rvm = config['rvm']['default']
      envy = get_envy_path

      Popo::Utils.popo_puts("Using #{default_rvm} as default ruby...")
      system "#{envy} rvm --default #{default_rvm}"
      Popo::Utils.popo_puts("Done!")
    end

    def self.get_envy_path
      File.join(Dir.pwd, @target_path, POPO_WORK_PATH, 'script/envy')
    end

    def self.premade_directories(root_path, popo_tree)
      popo_tree.each do |dir|
        directory_path = File.join(root_path, @target_path, dir)
        unless File.exist? directory_path
          Popo::Utils.popo_puts("Creating directory #{directory_path}")
          FileUtils.mkdir_p(directory_path)
        end
      end
    end

  end # Class Deployer
end

