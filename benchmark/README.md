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
go version go1.24.1 darwin/arm64
ruby 3.4.1 (2024-12-25 revision 48d4efcb85) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          sequential     1.000 i/100ms
FunnelHttp::Client#perform
                         2.000 i/100ms
 Parallel with Fiber     1.000 i/100ms
Calculating -------------------------------------
          sequential      6.951 (± 0.0%) i/s  (143.86 ms/i) -     35.000 in   5.049849s
FunnelHttp::Client#perform
                         22.720 (±48.4%) i/s   (44.01 ms/i) -     86.000 in   5.137729s
 Parallel with Fiber      3.699 (± 0.0%) i/s  (270.35 ms/i) -     19.000 in   5.177063s

Comparison:
FunnelHttp::Client#perform:       22.7 i/s
          sequential:        7.0 i/s - 3.27x  slower
 Parallel with Fiber:        3.7 i/s - 6.14x  slower
```
