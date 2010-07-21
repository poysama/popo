# add additional commands for the originally loaded popo
COMMANDS.concat %w{ bash rvm info status sync gems }

BASH_BIN = `which bash`.strip
ENV_BIN = `which env`.strip
POPORC = 'scripts/poporc'
GIT_REPO = 'git@git.caresharing.eu'

module Popo
  def self.commands(root_path, opts, opts_parse, argv = [ ])
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
    when 'gems'
      Popo.gems
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

  def self.gems
    POPO_CONFIG['gems'].each do |gem|
      gem.each do |gem_name, ver|
        tmp = []
        if ver.is_a? Array
          tmp = ver
        else
          tmp << ver
        end
        tmp.each do |ver2|
          system "gem install #{gem_name} -v #{ver2} --source http://gems.caresharing.eu --no-ri --no-rdoc"
        end
      end
    end
  end

  def self.palmade
    POPO_CONFIG['palmade']['gems'].each do |gem|
      
    end
  end
end

