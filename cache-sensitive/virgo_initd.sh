#!/usr/bin/env bash
/vnf/archbench/memory_tests/randacc 20 2>&1 >/dev/null | /vnf/simple-em/simple-em
