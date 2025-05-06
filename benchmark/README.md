# benchmark for funnel_http
## Usage
```bash
docker compose up --build
```

```bash
bundle exec ruby benchmark.rb
```

## Report
```
go version go1.24.2 darwin/arm64
ruby 3.4.3 (2025-04-14 revision d0b7e5b6a0) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          sequential     1.000 i/100ms
FunnelHttp::Client#perform
                         3.000 i/100ms
Parallel with Ractor     1.000 i/100ms
 Parallel with Fiber     1.000 i/100ms
Calculating -------------------------------------
          sequential      7.075 (±14.1%) i/s  (141.35 ms/i) -     21.000 in   3.149242s
FunnelHttp::Client#perform
                         31.001 (± 6.5%) i/s   (32.26 ms/i) -     93.000 in   3.020308s
Parallel with Ractor     16.888 (±29.6%) i/s   (59.21 ms/i) -     47.000 in   3.014063s
 Parallel with Fiber      6.406 (±31.2%) i/s  (156.10 ms/i) -     17.000 in   3.229245s

Comparison:
FunnelHttp::Client#perform:       31.0 i/s
Parallel with Ractor:       16.9 i/s - 1.84x  slower
          sequential:        7.1 i/s - 4.38x  slower
 Parallel with Fiber:        6.4 i/s - 4.84x  slower
```
