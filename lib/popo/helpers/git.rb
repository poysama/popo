module Popo::Helpers
  module Git
    def self.clone(repo, branch, target=nil)
      `git clone #{repo} -b #{branch} #{target}`
    end
  end
end

