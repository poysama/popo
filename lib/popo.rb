require 'rubygems'
require 'palmade/cableguy'
require 'optparse'
require 'yaml'
require 'fileutils'

module Popo
  POPO_LIB_ROOT = File.join(File.dirname(__FILE__), 'popo')

  autoload :Constants, (File.join(POPO_LIB_ROOT, 'constants'))
  autoload :Database, (File.join(POPO_LIB_ROOT, 'database'))
  autoload :GitUtils, (File.join(POPO_LIB_ROOT, 'git_utils'))
  autoload :Initializer, (File.join(POPO_LIB_ROOT, 'initializer'))
  autoload :Runner, (File.join(POPO_LIB_ROOT, 'runner'))
  autoload :RVM, (File.join(POPO_LIB_ROOT, 'rvm'))
  autoload :Sync, (File.join(POPO_LIB_ROOT, 'sync'))
  autoload :Utils, (File.join(POPO_LIB_ROOT, 'utils'))
end
