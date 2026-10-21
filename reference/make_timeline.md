# Generate a daily population timeline

Creates a population with individual reproduction numbers, admission
dates, lengths of stay, and optional attributes. Individuals are present
from admission up to, but excluding, discharge.

## Usage

``` r
make_timeline(
  n,
  dates,
  attributes = list(),
  admission_delay = 0,
  stay = 7:14,
  R = 2
)
```

## Arguments

- n:

  Number of individuals.

- dates:

  Vector of unique dates.

- attributes:

  Named list of attribute values and their sampling weights.

- admission_delay:

  Possible admission delays (days from the first date).

- stay:

  Possible lengths of stay (days).

- R:

  Possible individual reproduction numbers.

## Value

A `nososim_timeline` tibble with one row per person-day, containing
`id`, `date`, `R_i`, and optional attributes.

## Examples

``` r
dates <- as.Date("2026-01-01") + 0:6
make_timeline(2, dates, stay = 3)
#> # A tibble: 6 × 3
#>   id    date         R_i
#>   <chr> <date>     <dbl>
#> 1 ID_1  2026-01-01     2
#> 2 ID_1  2026-01-02     2
#> 3 ID_1  2026-01-03     2
#> 4 ID_2  2026-01-01     2
#> 5 ID_2  2026-01-02     2
#> 6 ID_2  2026-01-03     2
```
