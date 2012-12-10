require 'logger'

module Popo
  class Base
    attr_reader :target, :options, :logger, :root

    def initialize(options)
      @logger = Logger.new(STDOUT)
      @options  = options
      @target = options[:target]
      @root = ENV['popo_path'] || @options[:path] || Dir.pwd
    end

    def work_path(manifest='')
      @work_path ||= File.join(@root, manifest)
    end
  end
end
