# nix-shell --pure ../risingwave-nix/shell.nix

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
  # See how openssl is configured: https://docs.rs/openssl/latest/openssl/
  # We don't go through pkg-config when linking dynamically
  # so we need to use LD_LIBRARY_PATH, since ld checks that for dyn linking.
  shellHook = with pkgs; ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${openssl.out}/lib:${curl.out}/lib
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
    wa() { cargo watch -x 'check --all-targets'; }
    cr() { cargo sweep --toolchains="nightly"; }
  '';
}
