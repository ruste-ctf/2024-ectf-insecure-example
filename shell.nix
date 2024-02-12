/**
 * @file "shell.nix"
 * @author Ben Janis
 * @brief Nix shell environment file
 * @date 2024
 *
 * This source file is part of an example system for MITRE's 2024 Embedded System CTF (eCTF).
 * This code is being provided only for educational purposes for the 2024 MITRE eCTF competition,
 * and may not meet MITRE standards for quality. Use this code at your own risk!
 *
 * @copyright Copyright (c) 2024 The MITRE Corporation
 */

{ pkgs ? import <nixpkgs> {}
  , fetchzip ? pkgs.fetchzip
  , fetchgit ? pkgs.fetchgit
  , fetchurl ? pkgs.fetchurl
  , unzip ? pkgs.unzip
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.gnumake
    pkgs.python39
    pkgs.gcc-arm-embedded
    pkgs.poetry
    pkgs.cacert
    (pkgs.callPackage custom_nix_pkgs/analog_openocd.nix { })
    pkgs.minicom
    pkgs.clang
    pkgs.llvmPackages.bintools
    pkgs.rustup
  ];

  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
 
  # eCTF2024lib = builtins.fetchGit {
  #   url = "https://github.com/ruste-ctf/eCTF-2024-lib.git";
  # };
  
  msdk = builtins.fetchGit {
    url = "https://github.com/Analog-Devices-MSDK/msdk.git";
    ref = "refs/tags/v2023_06";
  };

  shellHook =
    ''
      # eCTF-2024-lib clone
      # rm -r $PWD/eCTF-2024-lib
      # cp -r $eCTF2024lib $PWD/eCTF-2024-lib
      # chmod -R u+rwX,go+rX,go-w $PWD/eCTF-2024-lib

      # msdk clone
      cp -r $msdk $PWD/msdk
      chmod -R u+rwX,go+rX,go-w $PWD/msdk
      export MAXIM_PATH=$PWD/msdk
    '';
}

