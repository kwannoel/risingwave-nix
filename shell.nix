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
    cr() { cargo sweep --toolchains="nightly"; }
    cl() { ./risedev clean-data; }
    fr() { ./risedev run-planner-test; }
    fs() { ./risedev apply-planner-test; }
    fa() { ./risedev do-apply-planner-test; }
    e2e() { ./risedev d; \
            ./risedev slt -p 4566 './e2e_test/streaming/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
  '';
}
