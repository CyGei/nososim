# Update individual attributes

Assigns attribute values to selected individuals over a date interval.

## Usage

``` r
set_attribute(timeline, id, from, to = NULL, attributes)
```

## Arguments

- timeline:

  A population timeline.

- id:

  Individual ID(s) to update.

- from:

  Start date (inclusive).

- to:

  End date (exclusive), or `NULL` for all subsequent dates.

- attributes:

  Named list of existing attributes and their new values.

## Value

The updated timeline.

## Examples

``` r
dates <- as.Date("2026-01-01") + 0:6
timeline <- make_timeline(2, dates, attributes = list(ward = c(A = 1)))
set_attribute(timeline, "ID_1", dates[3], attributes = list(ward = "B"))
#> # A tibble: 14 × 4
#>    id    date         R_i ward 
#>    <chr> <date>     <dbl> <chr>
#>  1 ID_1  2026-01-01     2 A    
#>  2 ID_1  2026-01-02     2 A    
#>  3 ID_1  2026-01-03     2 B    
#>  4 ID_1  2026-01-04     2 B    
#>  5 ID_1  2026-01-05     2 B    
#>  6 ID_1  2026-01-06     2 B    
#>  7 ID_1  2026-01-07     2 B    
#>  8 ID_2  2026-01-01     2 A    
#>  9 ID_2  2026-01-02     2 A    
#> 10 ID_2  2026-01-03     2 A    
#> 11 ID_2  2026-01-04     2 A    
#> 12 ID_2  2026-01-05     2 A    
#> 13 ID_2  2026-01-06     2 A    
#> 14 ID_2  2026-01-07     2 A    
```
