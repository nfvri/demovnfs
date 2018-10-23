#!/usr/bin/env bash
/vnf/archbench/memory_tests/seqacc 80 &
/vnf/archbench/memory_tests/seqacc 80 &
/vnf/archbench/memory_tests/seqacc 80 &
/vnf/archbench/memory_tests/seqacc 80 2>&1 >/dev/null | /vnf/simple-em/simple-em
