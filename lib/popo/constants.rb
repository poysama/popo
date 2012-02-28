module Popo
  module Constants
    POPORC              = 'script/poporc'
    DEFAULT_CONFIG_FILE = "popo_config.yml"
    DEFAULT_POPO_TARGET = "development"
    POPO_WORK_PATH      = ".manifest"
    POPO_YML_FILE       = "popo.yml"
    POPO_CONFIG         = {}
    POPO_DIR_KEY        = "sync.directories"
    POPO_KEY_VALUES     = ['branch', 'repo']
    POPO_COMMANDS       = ['sync', 'rvm', 'migrate', 'diff', 'status']
  end
end
