require 'thor'

module Popo
  class CLI < Thor
    include DSL
    include Constants

    @options = options

    option :verbose, :type => :boolean, :default => false
    option :force, :aliases => "-f", :type => :boolean, :default => false

    desc "init MANIFEST", "initialize a deployment given a manifest"
    method_option :path, :banner => '<path>', :aliases => "-p", :default => Dir.pwd
    method_option :source, :banner => '<source>', :aliases => "-s", :required => true
    method_option :target, :banner => '<target>', :aliases => "-t", :default => DEFAULT_POPO_TARGET

    def init(name)
      base = Base.new(@options)
      manifest = Manifest.new(base, name, base.options)

      deploy manifest do
        data = download
        load_config(data)
        log.info "Root is #{base.root}"
        base.work_path(manifest.name)
        log.info "Work path is #{base.work_path}"

        if File.exists?(manifest.path) and !options[:force]
          log.error "Manifest exists. Use --force to override"
        else
          log.info "Force delete old deployment..."
          clean
          log.info "Initializing..."
          setup

          db_options = {
            :path => manifest.path,
            :target => ENV['CABLING_TARGET'] || @options[:target],
            :verbose => @options[:verbose]
          }

          log.info "Populating data..."
          migrate(db_options)
          log.info "Writing config.."
          write_config
          log.info "Init done!"
        end
      end
    end

    desc "install PACKAGE", "install a packager"
    def install(package)
      puts package

    end

    desc "bash", "Enter popo interactive bash"
    def bash
    end

    desc "sync", "Update given repo"
    def sync

    end

    desc "release", "Make a release"
    def release

    end

    desc "diff", "Show difference from master and development branch"
    def diff

    end

    desc "migrate", "Migrate newly fetch data for popo"
    def migrate

    end

    private

    def runner(args, options)
      @runner = Runner.new(args, options)
    end
  end
end
