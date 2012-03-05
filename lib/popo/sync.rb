module Popo
  class Sync
    include Constants

    def initialize(popo_path, args, db)
      @db = db
      @sync_list = @db.get(POPO_DIR_KEY).split(',')
      @popo_path = popo_path
      @cwd = Dir.pwd
      @projects = args
      @info = {}
    end

    def sync
      @projects.each do |project|
        if project =~ /\//
          @info['key'] = convert_to_key(project)
          @info['path'] = File.join(@popo_path, project)

          get_values(@info['key'])

          get_project
        else
          sync_all(project)
        end
      end

      if @projects.empty?
        if @cwd.eql? @popo_path
          @sync_list.each { |p| sync_all(p) }
        else
          project = @cwd.split('/') - @popo_path.split('/')

          sync_all(convert_to_key(project))
        end
      end
    end

    def sync_all(project)
      if @sync_list.include? project
        children = @db.get_children(project)

        if children.empty?
          Error.say "No values for parent key \'#{project}\'."
        end

        children.each do |c|
          @info['key'] = [project, c].join('.')

          get_values(@info['key'])

          @info['path'] = File.join(@popo_path, project.gsub('.','/'), c)

          get_project
        end
      else
        get_values(project)

        @info['path'] = File.join(@popo_path, project.gsub('.','/'))

        get_project
      end
    end

    def get_project
      if !File.exists?(@info['path'])
        GitUtils.git_clone(@info['repo'], @info['path'], @info['branch'])
      else
        if POPO_CONFIG['target'] == DEFAULT_POPO_TARGET
          GitUtils.git_stash(@info['path'])
        end

        GitUtils.git_update(@info['path'], @info['branch'])
      end
    end


    def get_values(key)
      POPO_KEY_VALUES.each do |v|
        @info[v] = @db.get("#{key}.#{v}")
      end
    end

    def convert_to_key(project)
      if project.is_a? String
        project.split('/').join('.')
      else
        project.join('.')
      end
    end
  end
end
