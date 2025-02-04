#!/bin/bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

function start_thing {
  echo -en "LOG: "$Blue$1" ... "$Color_Off
}

function done_thing {
  echo -e $BIGreen"Done!"$Color_Off
}

function skip_thing {
  echo -e "LOG: "$Blue$1" ... "$BIYellow"Skip"$Color_Off
}

function upload() {
  start_thing "Uploading"
  if openocd -s $MAXIM_PATH/Tools/OpenOCD/scripts -f interface/cmsis-dap.cfg -f target/max78000.cfg -c "program $1 verify; init; reset run; exit" > $EXAMPLE_PATH/lib-build/openocd.log 2>&1; then
    done_thing
  else
    echo -e $BIRed"Failed to upload"$Color_Off
    cat $EXAMPLE_PATH/lib-build/openocd.log
    echo
    echo "--------------------------------------------------------------------------------"
    echo "Are you sure the board is plugged in?"
    echo
    echo "If you are sure the board is plugged-in and"
    echo "working, you can try to follow the below"
    echo "guide on how to set linux permissions for DAPLINK."
    echo "https://forgge.github.io/theCore/guides/running-openocd-without-sudo.html"
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    exit 1
  fi
}


if [ ! -f user_dir_config.cfg ]; then
  echo -e $BIRed"Cannot Find 'user_dir_config.cfg' making a new one..."$Color_Off
  touch user_dir_config.cfg
  echo -e "# Put your paths to the libs in here!" >> user_dir_config.cfg
  echo "export HAL_PATH=\"/path/to/max78000\"" >> user_dir_config.cfg
  echo "export LIB_PATH=\"/path/to/eCTF-2024-lib\"" >> user_dir_config.cfg
  echo "export EXAMPLE_PATH=\"/path/to/2024-insecure-example\"" >> user_dir_config.cfg
  echo "export MAXIM_PATH=\"/path/to/msdk\"" >> user_dir_config.cfg
  echo  >> user_dir_config.cfg
  echo
  echo "Please change the paths in 'user_dir_config.cfg' to match the real paths"
  echo "of the objects specified."
  exit 1
fi

source user_dir_config.cfg

if [ ! -d $HAL_PATH ]; then
  echo -e $BIRed"Cannot find directory: HAL_PATH ($HAL_PATH), please" 
  echo -e "update 'user_dir_config.cfg' with the correct path!"$Color_Off
  exit 1
fi
  
if [ ! -d $LIB_PATH ]; then
  echo -e $BIRed"Cannot find directory: LIB_PATH ($LIB_PATH), please" 
  echo -e "update 'user_dir_config.cfg' with the correct path!"$Color_Off
  exit 1
fi

if [ ! -d $EXAMPLE_PATH ]; then
  echo -e $BIRed"Cannot find directory: EXAMPLE_PATH ($EXAMPLE_PATH), please" 
  echo -e "update 'user_dir_config.cfg' with the correct path!"$Color_Off
  exit 1
fi

if [ ! -d $MAXIM_PATH ]; then
  echo -e $BIRed"Cannot find directory: MAXIM_PATH ($MAXIM_PATH), please" 
  echo -e "update 'user_dir_config.cfg' with the correct path!"$Color_Off
  exit 1
fi

DEBUG_MODE=1
TARGET_PATH="debug"
CARGO_OPTION=""

if [ -z $1 ]; then
  echo -e $BIRed"Please provide 'comp' or 'ap' to select target"$Color_Off
  exit 1
elif [ $1 = "comp" ]; then
  COMP_OR_AP="comp"
elif [ $1 = "ap" ]; then
  COMP_OR_AP="ap"
else
  echo -e $BIRed"Unknown Option:\nHelp:\n\tComponent: 'comp'\n\tApplication Processor: 'ap'\n"$Color_Off
  exit 1
fi

if [ -z $2 ]; then
  echo -e $BIYellow"No Option Provided, defaulting to Debug Mode..." $Color_Off
  DEBUG_MODE=1
  TARGET_PATH="debug"
  CARGO_OPTION=""
elif [ $2 = "--debug" ]; then
  echo -e $BIGreen"Compiling in Debug Mode"$Color_Off
  DEBUG_MODE=1
  TARGET_PATH="debug"
  CARGO_OPTION=""
elif [ $2 = "--release" ]; then
  echo -e $BIGreen"Compiling in Release Mode"$Color_Off
  DEBUG_MODE=0
  TARGET_PATH="release"
  CARGO_OPTION="--release"
else
  echo -ne $BIRed"Unknown Option:\nHelp:\n\tDebug Mode: --debug\n\tRelease Mode: --release\n\n" $Color_Off
  exit 1
fi

cd $EXAMPLE_PATH
if [ -d ./msdk ]; then
  skip_thing "MSDK Exists"
else
  start_thing "Cloning MSDK"
  git clone https://github.com/Analog-Devices-MSDK/msdk.git
  chmod -R u+rwX,go+rX,go-w ./msdk
  end_thing
fi

if [ -d $EXAMPLE_PATH/lib-build ]; then
  skip_thing "'lib-build' exists"
else
  start_thing "Making 'lib-build' directory"
  mkdir $EXAMPLE_PATH/lib-build
  done_thing
fi

start_thing "Building eCTF-2024-lib"
cd $LIB_PATH
if script -e --quiet -c "cargo build $CARGO_OPTION" -O $EXAMPLE_PATH/lib-build/cargo.log > /dev/null 2>&1; then
done_thing
else
echo -e $BIRed"Cargo Build Failed!!"$Color_Off
cat $EXAMPLE_PATH/lib-build/cargo.log
exit 1
fi

start_thing "Copying Artifacts"
cp $LIB_PATH/target/thumbv7em-none-eabi/$TARGET_PATH/libectf_2024.a $EXAMPLE_PATH/lib-build/libectf_2024.a
cd $EXAMPLE_PATH
done_thing

start_thing "Running Poetry Install"
poetry install > $EXAMPLE_PATH/lib-build/poetry.log 2>&1
done_thing
start_thing "Building Dependencies"
poetry run ectf_build_depl -d . >> $EXAMPLE_PATH/lib-build/poetry.log 2>&1
done_thing

if [ $COMP_OR_AP = "ap" ]; then
  start_thing "Building Application Processor"
  if poetry run ectf_build_ap -d . -on ap --p 123456 -c 2 -ids "0x11111124, 0x11111125" -b "Test boot message" -t 0123456789abcdef -od build >> $EXAMPLE_PATH/lib-build/poetry.log 2>&1; then
    done_thing
  else
    echo -e $BIRed"Failed to build Application Processor"$Color_Off
    cat $EXAMPLE_PATH/lib-build/poetry.log
    exit 1
  fi
  upload "build/ap.elf"
elif [ $COMP_OR_AP = "comp" ]; then
  start_thing "Building Component"
  if poetry run ectf_build_comp -d . -on comp -od build -id 0x11111125 -b "Component boot" -al "McLean" -ad "08/08/08" -ac "Fritz" >> $EXAMPLE_PATH/lib-build/poetry.log 2>&1; then
    done_thing
  else
    echo -e $BIRed"Failed to build Component"$Color_Off
    cat $EXAMPLE_PATH/lib-build/poetry.log
    exit 1
  fi
  upload "build/comp.elf"
else
  echo "Dont know how we got here, but failing!"
  exit 1
fi


start_thing "Waiting for device to reconnect"
while [ ! -e /dev/ttyACM0 ]; do
  echo -n "."
  sleep 1
done
done_thing

start_thing "Connecting"
echo
poetry run ectf_term --port /dev/ttyACM0
