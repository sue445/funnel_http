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
                         2.000 i/100ms
Parallel with Ractor     1.000 i/100ms
 Parallel with Fiber     1.000 i/100ms
Calculating -------------------------------------
          sequential      6.429 (±15.6%) i/s  (155.55 ms/i) -     32.000 in   5.074965s
FunnelHttp::Client#perform
                         25.100 (±35.9%) i/s   (39.84 ms/i) -    102.000 in   5.147337s
Parallel with Ractor      5.353 (±18.7%) i/s  (186.81 ms/i) -     23.000 in   9.159340s
 Parallel with Fiber      4.147 (±48.2%) i/s  (241.16 ms/i) -     18.000 in   5.046421s

Comparison:
FunnelHttp::Client#perform:       25.1 i/s
          sequential:        6.4 i/s - 3.90x  slower
Parallel with Ractor:        5.4 i/s - 4.69x  slower
 Parallel with Fiber:        4.1 i/s - 6.05x  slower
```
