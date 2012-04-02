require 'optparse'

module Popo
  class OptParse
    include Constants

    attr_reader :optparse, :options

    def initialize
      @options = {}
      @options[:verbose] = false

      @optparse = OptionParser.new do |options|
        options.banner = "Usage: popo COMMAND [options]"
        options.separator ""
        options.separator "Commands: #{POPO_COMMANDS.join(',')}"
        options.separator ""
        options.separator "options:"

        options.on('-p', '--path PATH', 'Target path') do |path|
          @options[:path] = path
        end

        options.on('-t', '--target TARGET', 'Deployment target') do |target|
          @options[:target] = target
        end

        options.on('-u', '--user USER', 'Specify a username for git') do |user|
          @options[:user] = user
        end

        options.on('-m', '--manifest MANIFEST', 'Specify a manifest repo') do |manifest|
          @options[:manifest] = manifest
        end

        options.on('-l', '--location LOCATION', 'Set the deployment location') do |location|
          @options[:location] = location
        end

        options.on('-r', '--reset', 'WARNING: It will not stash changes') do
          @options[:reset] = true
        end

        options.on('-v', '--verbose', 'Prints more info about what you executed') do
          @options[:verbose] = true
        end

        options.on('-V', '--version', 'Show popo\'s current version') do
          puts Popo::VERSION
          exit
        end

        options.on('-h', '--help', 'Display this screen') do
          puts options
          exit
        end
      end
    end
  end
end
