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
Warming up --------------------------------------
FunnelHttp::Client#perform
                         2.000 i/100ms
Parallel with 4 processes
                         1.000 i/100ms
Parallel with 4 threads
                         1.000 i/100ms
Calculating -------------------------------------
FunnelHttp::Client#perform
                         21.816 (± 4.6%) i/s   (45.84 ms/i) -     44.000 in   2.026960s
Parallel with 4 processes
                         15.785 (± 6.3%) i/s   (63.35 ms/i) -     32.000 in   2.035628s
Parallel with 4 threads
                         18.570 (±10.8%) i/s   (53.85 ms/i) -     37.000 in   2.008485s

Comparison:
FunnelHttp::Client#perform:       21.8 i/s
Parallel with 4 threads:       18.6 i/s - 1.17x  slower
Parallel with 4 processes:       15.8 i/s - 1.38x  slower
```