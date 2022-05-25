{ pkgs ? import <nixpkgs> {} }:


let unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
    baseInputs = with pkgs; [
    # std
    pkg-config openssl

    # deps
    protobuf
    cacert curl cmake
    git tmux ncurses postgresql

    # build
    lld
    which
    less

    # rust
    rustup
    cargo-make
    cargo-sweep

    # tools
    ripgrep
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
    fr() { ./risedev run-planner-test; }
    fs() { ./risedev apply-planner-test; }
    fa() { ./risedev do-apply-planner-test; }
    e2e() { ./risedev d; \
            ./risedev slt -p 4566 './e2e_test/streaming/**/*.slt'; \
            ./risedev slt -p 4566 './e2e_test/batch/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    e2es() { ./risedev d; \
            ./risedev slt -p 4566 './e2e_test/streaming/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    e2eb() { ./risedev d; \
            ./risedev slt -p 4566 './e2e_test/batch/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    w() { cargo watch; }
    cr() { cargo sweep --toolchains="nightly"; }
  '';
}
