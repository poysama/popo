module Popo
  class Sync
    def initialize(app_root, args, db)
      @db = db
      @current_dir = File.basename(Dir.pwd)
      @app_root = app_root
      @cwd = Dir.pwd
      @repos = args
      @info = {}
    end

    def gather
      @repos.each do |repo|
        if repo =~ /\//
          r = repo.split('/')
          @info[:parent], @info[:name] = r
          @info[:key] = [@info[:parent], @info[:name]].join('.')
          @info[:path] = File.join(@app_root, @info[:parent], @info[:name])

          get_repo_values(@info[:key])

          clone_or_update
        else
          gather_many(repo)
        end
      end

      if @repos.empty?
        if @cwd.eql? @app_root
          popo_folders = @db.get("sync.directories").split(',')
          popo_folders.each { |p| gather_many(p) }
        else
          repo = File.basename(@cwd)
          gather_many(repo)
        end
      end
    end

    def gather_many(repo)
      children = @db.get_children(repo)

      raise "No values for parent key \'#{repo}\'." if children.empty?

      children.each do |c|
        @info[:key] = [repo, c].join('.')
        get_repo_values(@info[:key])
        @info[:path] = File.join(@app_root, repo,  c)

        clone_or_update
      end
    end

    def clone_or_update
      if !File.exists?(@info[:path])
        GitUtils.git_clone(@info[:host], @info[:path], @info[:branch])
      else
        GitUtils.git_stash(@info[:path]) if POPO_CONFIG['target'] == 'development'
        GitUtils.git_update(@info[:path], @info[:branch])
      end
    end


    def get_repo_values(key)
      @info[:branch] = @db.get("#{key}.branch")
      @info[:host] = @db.get("#{key}.repo")
    end
  end
end
