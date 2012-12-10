module Popo
  module DSL
    def deploy(manifest, &block)
      manifest.instance_eval(&block)
    end
  end
end
