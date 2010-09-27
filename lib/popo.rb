# add additional commands for the originally loaded popo

COMMANDS.concat %w{ bash rvm info status cable reconfigure rvm_update}

BASH_BIN = `which bash`.strip
ENV_BIN = `which env`.strip
POPORC = 'scripts/poporc'
GIT_REPO = 'git@git.caresharing.eu'
POPO_ROOT = ENV['popo_path']

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
    when 'clone'
      Popo.clone(argv)
    when 'reconfigure'
      Popo.reconfigure(root_path, options)
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
    # refactor
  end

  def self.reconfigure(root_path, options)
    if ENV['popo_target'].nil? || ENV['popo_path'].nil?
      fail_exit "Popo is not loaded. popo bash perhaps?"
    else
      require File.join(ENV['popo_path'], '.popo/lib/hash.rb')
    end

    target = POPO_CONFIG['target']
    root_path = root_path.split('/')
    options[:dir] = root_path.pop
    root_path = root_path.join('/')
    Popo.configure(root_path, target, options)

    # merge
    options[:file] = 'cabling'
    Popo.merge(root_path, target, options)
    options[:file] = 'popo'
    Popo.merge(root_path, target, options)
  end
  
  def self.merge(root_path, target, options)
    dir = options[:dir]
    file = options[:file]
    root_path = "#{root_path}/#{dir}/#{POPO_WORK_PATH}"
    
    if File.exist? "#{root_path}/#{file}-defaults.yml"
      defaults_file = YAML.load_file("#{root_path}/#{file}-defaults.yml")
    else
      fail_exit "#{file}-defaults not found."
    end

    if File.exist? "#{root_path}/#{file}-local.yml"
      local_file = YAML.load_file("#{root_path}/#{file}-local.yml")        
    else
      fail_exit "#{file}-local not found."
    end

    if local_file.is_a? Hash
      defaults_file.deep_merge! local_file
    end
    
    generated_file = YAML.dump(defaults_file)
    generated_file.gsub!(/^---/,"# Generated #{file}.yml #{Time.now}. This file is auto generated and must not be edited.")
    generated_file.gsub!(/\%target\%/, target)

    File.open("#{root_path}/#{file}.yml" , "w") { |f| f.write(generated_file) }

    # remove defaults file
    FileUtils.rm("#{root_path}/#{file}-defaults.yml")
  end

  def self.rvm_update
    Dir.chdir("#{POPO_ROOT}/rvm")
    system("git reset --hard")
    system("git pull")
  end
  
  def self.clone
  end
end
