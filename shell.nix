{ pkgs ? import <nixpkgs> {} }:


let unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
    baseInputs = with pkgs; [
    protobuf pkg-config openssl
    rustup cacert curl which cmake
    git tmux ncurses postgresql
    less cargo-sweep
  ];

in
pkgs.mkShell {
  buildInputs = baseInputs ++ [unstable.yq-go];
}
