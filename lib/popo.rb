# add additional commands for the originally loaded popo
COMMANDS.concat %w{ sync }

module Popo
  def self.proxy_commands(root_path, opts, opts_parse, argv = [ ])
    case argv[0]
    when 'sync'
      Popo.sync(root_path)
    else
      opts_parse.help
    end
  end
end

