# add additional commands for the originally loaded popo

COMMANDS.concat %w{ bash rvm info status cable reset}

BASH_BIN = `which bash`.strip
ENV_BIN = `which env`.strip
POPORC = 'scripts/poporc'
GIT_REPO = 'git@git.caresharing.eu'
POPO_ROOT = ENV['popo_path']
VALID_MODS = { 'frameworks' => 'f', 'plugins' => 'p', 'apps' => 'a' }

module Popo
  def self.commands(root_path, options, optparse, argv = [ ])
    case argv[0]
    when 'sync'
      Popo.sync(root_path)
    when 'info'
      Popo.info(root_path)
    when 'status'
      Popo.status(root_path)
    when 'bash'
      Popo.bash(root_path)
    when 'rvm'
      Popo.rvm(root_path, argv)
    when 'rvm_update'
      Popo.rvm_update
    when 'cable'
      Popo.cable
    when 'reset'
      if ENV['popo_target'].eql? 'production'
        popo_puts "[Popo]: You cannot reset in production mode"
      else
        Popo.reset
      end
      #fail_exit "Reset is disabled."
    when 'clone'
      Popo.clone(argv)
    when 'configure'
      root_path = root_path.split('/')
      options[:dir] = root_path.pop
      root_path = root_path.join('/')
      puts root_path.inspect
      Popo.configure(root_path, POPO_CONFIG['target'], options)
    else
      puts "FAIL me not know some command #{argv[0]}\n\n"
      puts opts_parse.help
    end
  end

  def self.check_extended_requirements!
    
  end

  def self.info(root_path)
    info = {
      "Work Path" => root_path,
      "Target" => POPO_CONFIG["target"]
    }

    info.each do |k,v|
      puts "#{k}: #{v}"
    end
  end

  def self.status(root_path)
    puts "Gathering status info, please be patient, this can take a while on a pathetic machine..."
    $stdout.flush
  end

  def self.bash(root_path)
    if BASH_BIN.nil? || BASH_BIN.empty?
      fail_exit! "FAIL bash is nowhere to be found"
    end

    if ENV_BIN.nil? || ENV_BIN.empty?
      fail_exit! "FAIL env is nowhere to be found"
    end

    target = POPO_CONFIG['target']
    bashcmd = "#{ENV_BIN} popo_target=#{target} popo_path=#{root_path} #{BASH_BIN} --rcfile #{File.join(root_path, POPO_WORK_PATH, POPORC)}"
    exec(bashcmd)
  end

  def self.rvm(root_path, argv)
    if ENV_BIN.nil? || ENV_BIN.empty?
      fail_exit! "FAIL env is nowhere to be found"
    end

    target = POPO_CONFIG['target']
    poporc_path = File.join(root_path, POPO_WORK_PATH, POPORC)

    if argv.size > 1
      bashcmd = "#{ENV_BIN} popo_target=#{target} popo_path=#{root_path} #{poporc_path} #{argv[1..-1].join(' ')}"
    else
      bashcmd = "#{ENV_BIN} popo_target=#{target} popo_path=#{root_path} #{poporc_path}"
    end
    exec(bashcmd)
  end

  def self.cable
    begin
      poop_yml = YAML::load_file(ENV['popo_path'] + '/.popo/poop.yml')
      if poop_yml['apps'].nil?
        apps_list = POPO_CONFIG['apps']
      else
        apps_list = poop_yml['apps']
      end
    rescue
      apps_list = POPO_CONFIG['apps']
    end

    apps_list.each do |app, v|
      if File.directory? "apps/#{app}"  
        Dir.chdir("apps/#{app}") { |p|
          puts "Cabling #{app}....."
          system("cable")
        }
      end
    end
  end

  def self.reset
    if ENV['popo_target'].nil? || ENV['popo_path'].nil?
      fail_exit "Popo is not loaded. popo bash perhaps?"
    else
      require File.join(ENV['popo_path'], '.popo/lib/hash.rb')
    end

    target = ENV['popo_target']    
    root_path = ENV['popo_path']
    
    combine(root_path, target, 'cabling')
    combine(root_path, target, 'dbget')
    combine(root_path, target, 'popo')
    combine(root_path, target, 'poop')
    
    popo_puts "[Popo]: Reset OK. May the force be with you."
  end
  
  def self.rvm_update
    Dir.chdir("#{POPO_ROOT}/rvm")
    system("git reset --hard")
    system("git pull")
  end
  
  def self.combine(root_path, target, file)
    full_root_path = "#{root_path}/.popo/#{file}"
    begin
      defaults_file = YAML::load_file("#{full_root_path}-defaults.yml")

      current_file = YAML::load_file("#{full_root_path}.yml")

      if current_file.is_a? Hash
        defaults_file.deep_merge! current_file
      else
        puts "[Popo]: #{file} is empty or does not exist. Creating a new one."
      end
      # patch fix for new yml, these values must be removed.
      defaults_file.delete('caresharing')
      defaults_file.delete('palmade')
      defaults_file.delete('git')
      final_file = YAML::dump(defaults_file)
      final_file.gsub!(/^---/,"# Generated #{file}.yml #{Time.now}")
      final_file.gsub!(/\%target\%/, target)

      File.open(full_root_path + '.yml' , 'w') { |f| f.write(final_file) }
    rescue

    end
  end

  def self.clone(argv)
  end
end
