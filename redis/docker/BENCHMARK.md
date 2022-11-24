# Redis benchmark commands

```redis-benchmark -t set,get -d 1000000 -n 1000 -c 100 -r 1000000 -l -q```

### Continuous streaming test
## High load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 1000000 -n 100 -c 1000 -r 1000000 -l -q ; done```

## Hard load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 1000000 -n 100 -c 500 -r 1000000 -l -q ; done```

## Normal load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 1000000 -n 100 -c 250 -r 1000000 -l -q ; done```

## low load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 1000000 -n 100 -c 100 -r 1000000 -l -q ; done```

### Continuous "high speed" streaming test
## High load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 500000 -n 100 -c 1000 -r 1000000 -l -q ; done```

## High load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 500000 -n 100 -c 500 -r 1000000 -l -q ; done```

## Normal load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 500000 -n 100 -c 250 -r 1000000 -l -q ; done```

## low load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 500000 -n 100 -c 100 -r 1000000 -l -q ; done```

### Continuous "transcoding" 10MB non-random test
## High load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 10000 -n 100000 -c 1000 -r 1000 -l -q ; done```

## Hard load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 10000 -n 100000 -c 500 -r 1000 -l -q ; done```

## Normal load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 10000 -n 100000 -c 250 -r 1000 -l -q ; done```

## low load
```while true; do redis-cli FLUSHDB; redis-benchmark -t set,get -d 10000 -n 100000 -c 100 -r 1000 -l -q ; done```

