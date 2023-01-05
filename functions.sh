  d() {
    ./risedev d;
  }

  a() {
    psql -h localhost -p 4566 -d dev -U root;
      }
  f() {
    psql -h localhost -p 4566 -d dev -U root -f "$@"
  }
  # run a single command in the data base
  rc() {
        ./risedev d; \
        psql -h localhost -p 4566 -d dev -U root -c "$@"
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
  e2ef() { ./risedev d; \
          ./risedev slt -p 4566 -d dev -u root "$@"; \
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
  wa() { cargo watch -x 'check --all-targets' --features enable_sqlsmith_unit_test; }
  cr() { cargo sweep --toolchains="nightly"; }
  fmt() { ./risedev c; }
  clippy() { cargo clippy --workspace --all-targets --fix --allow-dirty; }
  sse2e() { cargo build; \
            ./risedev d; \
            ./target/debug/sqlsmith test --testdata ./src/tests/sqlsmith/tests/testdata; \
          }
  pg() {
      docker run --name basic-postgres --rm -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=abc -e PGDATA=/var/lib/postgresql/data/pgdata --mount type=tmpfs,destination=/var/lib/postgresql/data/ -p 5432:5432 -it postgres:14.1-alpine
  }
  pgc() {
      psql -h localhost -p 5432 -U postgres
  }
  ssf() {
      ./risedev test run_sqlsmith_on_frontend_0 --features enable_sqlsmith_unit_test
  }
  ssff() {
      ./risedev test -E "package(risingwave_sqlsmith)" --features enable_sqlsmith_unit_test
  }

  sqlancer() {
      cd sqlancer
      mvn package -DskipTests
      cd target
      java -jar sqlancer-*.jar --num-threads 4 sqlite3 --oracle NoREC
  }