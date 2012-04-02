module Popo
  module Constants
    POPORC              = "script/poporc"
    DEFAULT_CONFIG_FILE = "popo_config.yml"
    DEFAULT_POPO_TARGET = "development"
    POPO_WORK_PATH      = ".manifest"
    POPO_YML_FILE       = "popo.yml"
    POPO_CONFIG         = {}
    POPO_DIR_KEY        = "sync.directories"
    POPO_KEY_VALUES     = %w(branch repo)
    POPO_COMMANDS       = %w(sync rvm migrate diff info update)
    REQUIRED_COMMANDS   = %w(git env)

    # colors
    COLOR_RED     = "\e[1;31m"
    COLOR_GREEN   = "\e[1;32m"
    COLOR_YELLOW  = "\e[1;33m"
    COLOR_NONE    = "\e[1;0m"

    POST_INSTALL_NOTE = <<NOTE
You're almost done!\n
Do the following inside popo:\n
1. rvm reload\n
NOTE
  end
end
