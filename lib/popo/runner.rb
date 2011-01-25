module Popo
  class Runner

    def self.run(args, options)
      root_path = options[:root_path]

      command = args.shift

      if command == 'init'
        if options[:manifest].nil? or options[:path].nil?
          err_msg = "init must be suppiled with a path and a manifest. Use -m and -p"
          Popo::Utils.popo_puts(err_msg, {:sub => true, :err => true})
        end

        unless Popo::Utils.in_popo?(root_path)
          Popo::Deployer.init(args, options)
        else
          Popo::Utils.popo_puts("Popo under popo? Seryos.", {:sub => true, :err => true })
        end
      else
        Popo::Utils.wrap_check(root_path)

        case command
        when 'reconfigure'
          err_msg = "reconfigure needs the -m option"

          if options[:manifest].nil?
            Popo::Utils.popo_puts(err_msg, {:sub => true, :err => true})
          end

          Popo::Popoized.reconfigure(root_path, options)
        when 'info'
          Popo::Popoized.info(root_path)
        when 'bash'
          Popo::Popoized.bash(root_path)
        else
          Popo::Utils.popo_puts 'Nothing to do...', { :sub => true }
        end
      end
    end

  end
end

