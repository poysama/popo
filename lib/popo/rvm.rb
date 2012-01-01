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
      Utils.say "Rubies to be installed #{@rubies}...\n\n"

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

      Utils.say_with_time "Setting #{@default_ruby} as default ruby..." do
       `#{@rvm_bin} --default #{@default_ruby}`
      end

      Utils.say(POST_INSTALL_NOTE)

#      Utils.say_with_time "Reloading rvm..." do
#        `#{@rvm_bin} reload`
#      end

#      @default_gems.each do |g|
#        Utils.say_with_time "Installing gem #{g}" do
#          `gem install #{g} --source #{@gem_source}`
#        end
#      end
    end
  end

POST_INSTALL_NOTE = <<NOTE
You're almost done!\n\n
Do the following inside popo:\n
1. rvm reload\n
2. gem install cableguy popo dbget_client --source http://gems.caresharing.eu --no-ri --no-rdoc\n\n
OPTIONAL: (If you use another ruby version). In this example, ree.\n
1. rvm use ree-1.8.7-2011.03\n
2. gem install cableguy popo dbget_client --source http://gems.caresharing.eu --no-ri --no-rdoc\n
NOTE

end
