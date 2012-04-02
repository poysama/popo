module Popo
  class RVM
    include Constants

    def initialize(runner)
      @db       = runner.database
      @repos    = runner.args
      @rvm_bin  = File.join(runner.app_root, 'rvm/bin/rvm')
      @app_root = runner.app_root

      if @db.has_key?("rvm.gems.source")
        @default_gem_source = @db.get("rvm.gems.source")
      end

      get_rubies
      set_rubies
    end

    def get_rubies
      @rubies = @db.get("rvm.rubies").split(",")
    end

    def set_rubies
      @default_ruby = @db.get("rvm.ruby.default")
      @default_gems = @db.get_children("rvm.gems.default")
    end

    def setup
      Utils.say "Rubies to be installed #{@rubies}...\n"

      @rubies.each do |r|
        patch = File.join(@app_root, 'rvm', "#{r}.patch")

        if File.exists?(patch)
          Utils.say("Patch for #{r} is found at #{patch}")
          cmd = "#{@rvm_bin} install #{r} --patch #{patch} --force"
        else
          cmd = "#{@rvm_bin} install #{r} --force"
        end

        system(cmd)
        install_default_gems(r)
      end

      Utils.say_with_time "Setting #{@default_ruby} as default ruby..." do
       `#{@rvm_bin} --default #{@default_ruby}`
      end

      Utils.say(POST_INSTALL_NOTE)
    end

    def install_default_gems(ruby_version)
      gem_source = ''
      gem_bin = File.join(@app_root, 'rvm', 'bin', "gem-#{ruby_version}")

      @default_gems.each do |g|
        if @db.has_key?("rvm.gems.default.#{g}.source")
          gem_source = @db.get("rvm.gems.default.#{g}.source")
        end

        if !gem_source.empty?
         gem_cmd = "#{gem_bin} install #{g} --source #{gem_source} --no-ri --no-rdoc"
        elsif !@default_gem_source.empty?
         gem_cmd = "#{gem_bin} install #{g} --source #{@default_gem_source} --no-ri --no-rdoc"
        else
         gem_cmd = "#{gem_bin} install #{g} --no-ri --no-rdoc"
        end

        system(gem_cmd)
      end
    end
  end
end
