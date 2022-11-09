# nix-shell --pure ../risingwave-nix/shell.nix

{ pkgs ? import <nixos> {} }:

# let unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
with pkgs;
let myPythonPkgs = python-packages: with python-packages; [ pglast ];
    myPython = python3.withPackages myPythonPkgs;
    baseInputs = [
    # std
    pkg-config openssl

    # deps
    protobuf
    cacert curl cmake
    git tmux ncurses postgresql_14

    # build
    lld
    which
    less
    yq-go

    # rust
    rustup
    cargo-make
    cargo-sweep

    # tools
    nix
    myPython # view postgres parser output
    ripgrep
    gdb
    ps
    shellcheck
    postgresql

    # dashboard
    nodejs
  ];

in
pkgs.mkShell {
  buildInputs = baseInputs; # ++ [unstable.yq-go];
  # See how openssl is configured: https://docs.rs/openssl/latest/openssl/
  # We don't go through pkg-config when linking dynamically
  # so we need to use LD_LIBRARY_PATH, since ld checks that for dyn linking.
  shellHook = with pkgs; ''
      export RUSTFLAGS="--cfg tokio_unstable"
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${openssl.out}/lib:${curl.out}/lib
      cd ~/projects/risingwave
      source functions.sh
  '';
}
