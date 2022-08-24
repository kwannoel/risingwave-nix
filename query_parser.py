#!/usr/bin/env python3

# USAGE: ./query_parser.py "select -1"

import sys
from pprint import pprint
from pglast import parse_sql
root = parse_sql(sys.argv[1])
rawstmt = root[0]
stmt = rawstmt.stmt
pprint(stmt(depth=10, skip_none=True))
