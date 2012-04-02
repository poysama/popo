require 'rubygems'
require 'palmade/cableguy'
require 'yaml'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'popo/version')

module Popo
  POPO_LIB_ROOT = File.join(File.dirname(__FILE__), 'popo')

  autoload :Constants, File.join(POPO_LIB_ROOT, 'constants')
  autoload :Database, File.join(POPO_LIB_ROOT, 'database')
  autoload :Error, File.join(POPO_LIB_ROOT, 'error')
  autoload :GitUtils, File.join(POPO_LIB_ROOT, 'git_utils')
  autoload :Init, File.join(POPO_LIB_ROOT, 'init')
  autoload :OptParse, File.join(POPO_LIB_ROOT, 'opt_parse')
  autoload :Runner, File.join(POPO_LIB_ROOT, 'runner')
  autoload :RVM, File.join(POPO_LIB_ROOT, 'rvm')
  autoload :Sync, File.join(POPO_LIB_ROOT, 'sync')
  autoload :Utils, File.join(POPO_LIB_ROOT, 'utils')
end
