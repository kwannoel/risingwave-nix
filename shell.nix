# nix-shell --pure ../risingwave-nix/shell.nix

{ pkgs ? import <nixos> {} }:

# let unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
let baseInputs = with pkgs; [
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
    ripgrep
    gdb
    ps
    shellcheck
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
    a() { ./risedev d; \
          psql -h localhost -p 4566 -d dev -U root;
        }
    k() { ./risedev k; }
    rl() { ./risedev l; }
    cl() { ./risedev clean-data; }
    fr() { ./risedev run-planner-test; }
    fs() { ./risedev apply-planner-test; }
    fa() { ./risedev do-apply-planner-test; }
    e2ebasic() { ./risedev d; \
            ./risedev slt -p 4566 -d dev -u root './e2e_test/streaming/basic.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    e2e() { ./risedev d; \
            ./risedev slt -p 4566 -d dev -u root -j 1 './e2e_test/streaming/**/*.slt'; \
            ./risedev slt -p 4566 -d dev -u root -j 1 './e2e_test/batch/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    e2es() { ./risedev d; \
            ./risedev slt -p 4566 -d dev -u root -j 1 './e2e_test/streaming/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    e2eb() { ./risedev d; \
            ./risedev slt -p 4566 -d dev -u root -j 1 './e2e_test/batch/**/*.slt'; \
            ./risedev k; \
            ./risedev clean-data; \
          }
    w() { cargo watch; }
    wa() { cargo watch -x 'check --all-targets'; }
    cr() { cargo sweep --toolchains="nightly"; }
    fmt() { ./risedev c; }
    clippy() { cargo clippy --workspace --all-targets --fix --allow-dirty; }
    sse2e() { cargo build; \
              ./risedev d; \
              ./target/debug/sqlsmith test --testdata ./src/tests/sqlsmith/tests/testdata; \
            }
  '';
}
