#!/bin/zsh

DEBUG=""
USAGE=1
ONE_TIME=1
LOG_LEVEL="d"

if [ ! -d /opt/generic_bash_functions ];then
    echo "/opt/generic_bash_functions not found, attemting to clone from lanthean's github"
    pushd /opt
    sudo git clone https://github.com/lanthean/generic_bash_functions.git
    popd
    sudo chown -R $USER:staff /opt/generic_bash_functions
fi
source /opt/generic_bash_functions/generic_bash_functions

function f_s_usage() {

    USAGE=0 # Usage is called, do not print eof

    echo " -"
    echo "| Usage $0 {--one-time} {-v/-vv}"
    echo "| --one-time: first run tasks that should be done once (lvextend, directory preparation)"
    echo "| -v/-vv    : show debug information"
    echo " --"
  }
function f_get_options(){
    #'Options manager: get arguments from cli and parse them'
    while [[ $# -ge 1 ]]    # -ge (greater or equal) because of --help (does not have pair = therefore in that case $# will be equal to 1)
    do  #; echo "key: "$1", value: "$2", remaining number: "$#
        if [[ $2 == "" || $2 == "-"* ]];then
            ERR="EMPTY_VALUE"
            ERR_OPT=$1
            break
        else
            case $1 in
            -v)
                DEBUG="-vvv"
                shift
                ;;
            -vv)
                DEBUG="-vvvv"
                shift
                ;;
            -o|--one-time)
                ONE_TIME=0
                shift
                ;;
            -\?|-h|--help)
                ERR="USAGE"
                USAGE=0
                shift
                ;;
            *)
                # unknown option
                ERR="UNKNOWN_OPT"
                ERR_OPT=$@
                ;;
            esac
            shift # past argument or value
        fi
    done

    if [[ $USAGE == 0 ]];then
        ERR="USAGE"
    # elif [[ $ERR == 0 ]]; then # $ERR == False
    #     if [[ $INPUT == "" || $OUTPUT == "" ]]; then
    #         ERR="BAD_MANDATORY"
    #     else
    #         # Check if $INPUT exists
    #         if [[ ! -d $INPUT ]];then 
    #             ERR="INPUT_NOT_A_DIRECTORY"
    #         fi
    #         # Check if $OUTPUT exists
    #         if [[ ! -d $OUTPUT ]];then
    #             ERR="OUTPUT_NOT_A_DIRECTORY"
    #         fi
    #     fi
    fi

    } 
function f_manage_err(){
    #'Error manager: take internal error and convert it to sensible output/exit code'
    case $ERR in
        "USAGE")
            f_s_usage
            ;;
        "UNKNOWN_OPT")
            log e "Unknown option used, please verify your syntax."
            log e "Input arguments used: "$@
            log e "Unknown argument: "$ERR_OPT
            f_s_usage
            ;;
        "BAD_MANDATORY")
            log e "Some mandatory parameter is missing, please consult usage."
            f_s_usage
            ;;
        "EMPTY_VALUE")
            log e "Attribute value cannot be empty. Please correct syntax of the attribute: $ERR_OPT"
            f_s_usage
            ;;
    #   "INPUT_NOT_A_DIRECTORY")
    #       log e "$INPUT path does not exist. Check your INPUT directory."
    #       ;;
    #   "OUTPUT_NOT_A_DIRECTORY")
    #       log w "$OUTPUT path does not exist. Creating it for you."
    #       [ $(mkdir $OUTPUT) ] && log i "$OUTPUT created"
    #       f_set_defaults
    #       f_main
    #       ;;
        *)
            log e "Unknown error."
            f_s_usage
            ;;
    esac
    }
function f_main() {

    private_key=/Users/lanthean/.ssh/id_rsa_vm

    # ansible-playbook -i hosts vm-one-time-setup.yml --extra-vars='target=all' --private-key=$private_key $DEBUG
    if [[ $ONE_TIME == 0 ]];then
        ansible-playbook -i hosts setup-vm.yml --extra-vars='target=all' --private-key=$private_key $DEBUG
    fi
    ansible-playbook -i localhost, setup-local.yml --private-key=$private_key $DEBUG

    }

f_get_options $@
if [[ $ERR == 0 ]];then
  f_main
else
  f_manage_err
fi
