# This script is a wrapper over the regular venv activation script, which should
# be renamed to 'activate_orig'. It sets an additional variable, PYTHONPATH, so
# that it contains reference to the site-packages of the venv. This allows
# Python binaries installed outside of the venv to use the packages installed
# inside the venv.
# 
# This essentially emulates the behavior of Ansible Tower/AWX, which allows
# Ansible (installed outside of the venv) to access the venv's site-packages.

if [ -n "$ZSH_VERSION" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${(%):-%x}" )" &> /dev/null && pwd )"
elif [ -n "$BASH_VERSION" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
else
   echo "Unrecognized shell"
   exit 1
fi
. $SCRIPT_DIR/activate_orig

PYTHON_LIBS=($VIRTUAL_ENV/lib/*)

_OLD_PYTHONPATH="$PYTHONPATH"
PYTHONPATH="${PYTHON_LIBS[0]}/site-packages:$PYTHONPATH"
export PYTHONPATH

# Rename deactivate to orig_deactivate
DEACTIVATE_FUNC_BODY=$(declare -f deactivate)
RENAMED_FUNC_BODY="${DEACTIVATE_FUNC_BODY/deactivate/orig_deactivate}"
eval "$RENAMED_FUNC_BODY"


deactivate () {
    # reset old environment variables
    # ! [ -z ${VAR+_} ] returns true if VAR is declared at all
    if ! [ -z "${_OLD_PYTHONPATH+_}" ] ; then
        if [ -z "$_OLD_PYTHONPATH" ] ; then
            unset PYTHONPATH
        else
          PYTHONPATH="$_OLD_PYTHONPATH"
          export PYTHONPATH
        fi
        unset _OLD_PYTHONPATH
    fi

    orig_deactivate
    unset -f orig_deactivate
}
