# Set individual weekly schedules

Removes days outside the specified weekdays for selected individuals.

## Usage

``` r
set_schedule(timeline, id, weekdays = 1:5)
```

## Arguments

- timeline:

  A population timeline.

- id:

  Individual ID(s) to update.

- weekdays:

  Weekdays to retain (Monday = 1, Sunday = 7).

## Value

The timeline with off-days removed for selected individuals.

## Examples

``` r
dates <- as.Date("2026-01-01") + 0:6
timeline <- make_timeline(2, dates)
set_schedule(timeline, "ID_1", weekdays = 1:5)
#> # A tibble: 12 × 3
#>    id    date         R_i
#>    <chr> <date>     <dbl>
#>  1 ID_1  2026-01-01     2
#>  2 ID_1  2026-01-02     2
#>  3 ID_1  2026-01-05     2
#>  4 ID_1  2026-01-06     2
#>  5 ID_1  2026-01-07     2
#>  6 ID_2  2026-01-01     2
#>  7 ID_2  2026-01-02     2
#>  8 ID_2  2026-01-03     2
#>  9 ID_2  2026-01-04     2
#> 10 ID_2  2026-01-05     2
#> 11 ID_2  2026-01-06     2
#> 12 ID_2  2026-01-07     2
```
