module Popo
  module GitUtils
    include Constants

    def self.git_clone(repo, clone_path = nil, branch)
      branch = 'master' if branch.nil?

      if clone_path.nil?
        cmd = "#{GIT_CMD} clone -b #{branch} #{repo}"
      else
        cmd = "#{GIT_CMD} clone -b #{branch} #{repo} #{clone_path}"
      end

      clone_msg = "Cloning branch #{branch} from #{repo}" +
                  " to #{clone_path}"

      Utils.say_with_time clone_msg do
       `#{cmd}`
      end
    end

    def self.git_update(repo, branch)
      Utils.say_with_time "Updating #{repo}" do
        Dir.chdir(repo) do
          `#{GIT_CMD} fetch`
        end
      end

      git_stash(repo)
      git_reset(repo, branch)
    end

    def self.git_stash(repo)
      Utils.say_with_time "Stashing changes for #{repo}" do
        Dir.chdir(repo) do
          `#{GIT_CMD} stash`
        end
      end
    end

    def self.git_reset(repo, branch)
      Utils.say_with_time "Doing a hard reset for #{repo}" do
        Dir.chdir(repo) do
          `#{GIT_CMD} reset --hard origin/#{branch}`
        end
      end
    end
  end
end

