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
FunnelHttp::Client#perform
                         1.000 i/100ms
Parallel with 4 processes
                         1.000 i/100ms
Parallel with 4 threads
                         1.000 i/100ms
Calculating -------------------------------------
FunnelHttp::Client#perform
                          1.434 (± 0.0%) i/s  (697.54 ms/i) -      8.000 in   5.768181s
Parallel with 4 processes
                          1.173 (± 0.0%) i/s  (852.63 ms/i) -      6.000 in   5.120296s
Parallel with 4 threads
                          1.110 (± 0.0%) i/s  (900.94 ms/i) -      6.000 in   5.413100s

Comparison:
FunnelHttp::Client#perform:        1.4 i/s
Parallel with 4 processes:        1.2 i/s - 1.22x  slower
Parallel with 4 threads:        1.1 i/s - 1.29x  slower
```
