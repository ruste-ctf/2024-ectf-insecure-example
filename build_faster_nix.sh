#!/bin/bash

echo $(pwd)

if [ -d ./msdk ]; then
  echo "MSDK Exists, skipping..."
else
  echo "Cloning MSDK"
  git clone https://github.com/Analog-Devices-MSDK/msdk.git
  chmod -R u+rwX,go+rX,go-w ./msdk
fi

echo "Exporting Enviroment"
export MAXIM_PATH="/home/corigan01/Programming/ruste-ctf/2024-ectf-insecure-example/msdk"

echo "Deleting eCTF-2024-lib, and re-copying"
rm -r ./eCTF-2024-lib/*
rm -r ./eCTF-2024-lib/.cargo
 
cp -r ../eCTF-2024-lib/* ./eCTF-2024-lib/
cp -r ../eCTF-2024-lib/.cargo ./eCTF-2024-lib/.cargo
rm ./eCTF-2024-lib/Cargo.lock
cd ./eCTF-2024-lib

echo "Building eCTF-2024-lib"
cargo build --release
cd ..

echo "Running Python build"
poetry install
poetry run ectf_build_depl -d .
poetry run ectf_build_ap -d . -on ap --p 123456 -c 2 -ids "0x11111124, 0x11111125" -b "Test boot message" -t 0123456789abcdef -od build

echo "Uploading ..."
poetry run ectf_update --infile ./build/ap.img --port /dev/ttyACM0
sleep 1
poetry run ectf_term --port /dev/ttyACM0
