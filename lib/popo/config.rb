require 'singleton'

module Popo
  class Config < Hash
    include Singleton

    def self.boot(data)

      config = self.instance
      config.merge!(YAML.load(ERB.new(data).result))
    end
  end
end
