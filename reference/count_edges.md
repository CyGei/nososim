# Count transmissions by attributes

Count edges between source and recipient groups, using their attributes
on the recipient's infection date. Initial cases are excluded.

## Usage

``` r
count_edges(x, by, by_date = FALSE)
```

## Arguments

- x:

  An object of class `nososim_outbreak`.

- by:

  Timeline attributes to group by.

- by_date:

  Also group by infection date? Defaults to `FALSE`.

## Value

A tibble with source and recipient attributes and transmission counts,
plus `date_infection` when `by_date = TRUE`.

## Examples

``` r
count_edges(outbreak, by = "ward")
#> # A tibble: 4 × 3
#>   source_ward recipient_ward transmissions
#>   <chr>       <chr>                  <int>
#> 1 A           A                          8
#> 2 A           B                         10
#> 3 B           A                          5
#> 4 B           B                          7
count_edges(outbreak, by = "ward", by_date = TRUE)
#> # A tibble: 21 × 4
#>    date_infection source_ward recipient_ward transmissions
#>    <date>         <chr>       <chr>                  <int>
#>  1 2026-01-04     A           A                          1
#>  2 2026-01-04     A           B                          1
#>  3 2026-01-05     A           B                          2
#>  4 2026-01-06     A           A                          1
#>  5 2026-01-06     B           B                          1
#>  6 2026-01-07     A           B                          1
#>  7 2026-01-07     B           A                          2
#>  8 2026-01-07     B           B                          2
#>  9 2026-01-08     A           A                          1
#> 10 2026-01-08     A           B                          2
#> # ℹ 11 more rows
count_edges(outbreak, by = c("ward", "role"))
#> # A tibble: 11 × 5
#>    source_ward source_role recipient_ward recipient_role transmissions
#>    <chr>       <chr>       <chr>          <chr>                  <int>
#>  1 A           patient     A              patient                    6
#>  2 A           patient     A              staff                      1
#>  3 A           patient     B              patient                    3
#>  4 A           patient     B              staff                      3
#>  5 A           staff       A              staff                      1
#>  6 A           staff       B              patient                    4
#>  7 B           patient     A              patient                    3
#>  8 B           patient     B              patient                    2
#>  9 B           patient     B              staff                      1
#> 10 B           staff       A              patient                    2
#> 11 B           staff       B              patient                    4
```
