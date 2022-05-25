{ pkgs ? import <nixpkgs> {} }:


let unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
    baseInputs = with pkgs; [
    protobuf pkg-config openssl
    rustup cacert curl which cmake
    git tmux ncurses postgresql
    less cargo-sweep
    cargo-make
    lld
  ];

in
pkgs.mkShell {
  buildInputs = baseInputs ++ [unstable.yq-go];
  shellHook = ''
    cd ~/projects/risingwave
    a() { ./risedev d; psql -h localhost -p 4566; }
    k() { ./risedev k; }
    rl() { ./risedev l; }
    cl() { ./risedev clean-data; }
  '';
}
