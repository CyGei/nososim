# Summarise a population timeline

Summarise a population timeline

## Usage

``` r
# S3 method for class 'nososim_timeline'
summary(object, ...)
```

## Arguments

- object:

  A timeline created by
  [`make_timeline()`](https://cygei.github.io/nososim/reference/make_timeline.md).

- ...:

  Unused.

## Value

A tibble with the number of individuals and person-days, overall and by
attribute value. Individuals may be counted in multiple groups if their
attributes change over time.

## Examples

``` r
timeline <- make_timeline(10, as.Date("2026-01-01") + 0:6,
  attributes = list(ward = c(A = 1, B = 1))
)
summary(timeline)
#> # A tibble: 3 × 4
#>   attribute value individuals person_days
#>   <chr>     <chr>       <int>       <int>
#> 1 NA        NA             10          70
#> 2 ward      A               8          56
#> 3 ward      B               2          14
```
