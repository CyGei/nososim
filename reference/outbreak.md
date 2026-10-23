# Example nosocomial outbreak

A simulated outbreak in a population of 40 people over 21 days, with
ward and role attributes, one imported case, and no intervention.
Generated with seed 123 by `inst/examples/outbreak.R`.

## Usage

``` r
outbreak
```

## Format

A `nososim_outbreak` list with population `timeline`, `infections`,
simulation `dates`, and `parameters`.

## Examples

``` r
summary(outbreak)
#> # A tibble: 1 × 7
#>   individuals simulation_days initial_cases secondary_cases total_cases
#>         <int>           <int>         <int>           <int>       <int>
#> 1          40              21             1              30          31
#> # ℹ 2 more variables: first_case <date>, last_case <date>
count_edges(outbreak, by = "ward")
#> # A tibble: 4 × 3
#>   source_ward recipient_ward transmissions
#>   <chr>       <chr>                  <int>
#> 1 A           A                          8
#> 2 A           B                         10
#> 3 B           A                          5
#> 4 B           B                          7
```
