module Popo
  class RVM
    def initialize(app_root, args, db)
      @db = db
      @app_root = app_root
      @rvm_bin = File.join(@app_root, 'rvm/bin/rvm')
      @repos = args

      @rubies = @db.get("rvm.rubies").split(",")
      @default_ruby = @db.get("rvm.ruby.default")
      @default_gems = @db.get("rvm.gems.default").split(",")
      @gem_source = @db.get("rvm.gems.source")
    end

    def setup
      @rubies.each do |r|
        patch = File.join(@app_root, 'rvm', "#{r}.patch")

        if File.exists?(patch)
          Utils.say("Patch for #{r} is found at #{patch}")
          cmd = "#{@rvm_bin} install #{r} --patch #{patch} --force"
        else
          cmd = "#{@rvm_bin} install #{r} --force"
        end

        system(cmd)
      end

      default_cmd = "#{@rvm_bin} --default #{@default_ruby}"

      system(default_cmd)
      system("#{@rvm_bin} reload")

      @default_gems.each do |g|
        `gem install #{g} --source #{@gem_source}`
      end
    end
  end
end
