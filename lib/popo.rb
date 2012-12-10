require 'rubygems'
require 'palmade/cableguy'
require 'yaml'
require 'fileutils'

module Popo
  autoload :Base, 'popo/base'
  autoload :Constants, 'popo/constants'
  autoload :CLI, 'popo/cli'
  autoload :Config, 'popo/config'
  autoload :Backends, 'popo/backends'
  autoload :DSL, 'popo/dsl'
  autoload :Error, 'popo/error'
  autoload :Helpers, 'popo/helpers'
  autoload :Manifest, 'popo/manifest'
  autoload :Packages, 'popo/packages'
  autoload :Project, 'popo/project'
  autoload :Version, 'popo/version'
end
