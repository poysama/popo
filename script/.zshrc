if [[ -z "$popo_path" ]] ; then
  echo "FAIL Please set the popo_path environment var"
  exit -1
fi

if [[ -z "$popo_target" ]] ; then
  echo "FAIL Please set the popo_target environment var"
  exit -1
fi

BASEPATH=`which basename`
BASENAME=`$BASEPATH $popo_path`


export rvm_reload_flag=1
export rvm_prefix=$popo_path

export CABLING_PATH=$popo_path/.manifest/cabling
export CABLING_TARGET=$popo_target

if [[ -n "$popo_location" ]] ; then
  export CABLING_LOCATION=$popo_location
fi

export DBGET_PATH=$popo_path/.manifest

unset $(env | awk -F= '/^rvm_/{print $1" "}')

export rvm_path=$popo_path/rvm
source $rvm_path/scripts/rvm

rubies_path=$rvm_path/rubies

unset PALMADE_GEMS_DIR
export PATH="$rvm_path/bin:$popo_path/tools:$PATH"

source ~/.zshrc

# Load default rvm if rubies folder is not empty
if [ -d $rubies_path ] && [ "$(ls -A $rubies_path)" ] ; then
  rvm default
fi

echo ""
echo "Welcome to the popoed zsh environment, where you can play with your very own popo."
echo ""
echo "  popo path: $popo_path"
echo "  popo target: $popo_target"
echo ""
echo "Remember to keep things clean and civil around here."
echo "To go back to your normal world, just hit exit."
echo ""
echo "But wait, you ask, who needs popo? Baahh, popo's for n00bs!"
echo ""
