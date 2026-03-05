# Converts data columns to a js array

`to_js_array()` takes a tibble with a grouping column and columns that
are to be combined into a js array.

## Usage

``` r
to_js_array(.data, .grp_var, ..., array_name)
```

## Arguments

- .data:

  tibble; data with grouping column and columns to be used to create the
  js array column

- .grp_var:

  grouping column

- ...:

  columns in .data that are to be used to create the js array column

- array_name:

  string; name of the newly created js array column

## Value

tibble with grouping column and js array column

## Details

The js array column that's created is list column of form \<array_name\>
= list(list(array_var1=var1val1, array_var2 = var2val1, ...),
list(array_var1=var1val2, array_var2=var2val2, ...), ...) for each
grouping variable category. I like to use the [dataui
package](https://timelyportfolio.github.io/dataui/articles/dataui_reactable.html)
along with the [reactable
package](https://glin.github.io/reactable/index.html). `dataui` is still
in more of a developmental phase and requires the data to be in this js
array like format.

## Examples

``` r
head(indiana_pos_rate)
#> # A tibble: 6 × 3
#>   end_date   msa         pos_rate
#>   <date>     <chr>          <dbl>
#> 1 2020-04-04 Bloomington   0.112 
#> 2 2020-04-11 Bloomington   0.125 
#> 3 2020-04-18 Bloomington   0.111 
#> 4 2020-04-25 Bloomington   0.0281
#> 5 2020-05-02 Bloomington   0.0232
#> 6 2020-05-09 Bloomington   0.0233

pos_rate_array <- to_js_array(.data = indiana_pos_rate,
                              .grp_var = msa,
                              end_date, pos_rate,
                              array_name = "posList")

head(pos_rate_array)
#> # A tibble: 6 × 2
#>   msa                          posList         
#>   <chr>                        <list>          
#> 1 Bloomington                  <named list [1]>
#> 2 Columbus                     <named list [1]>
#> 3 Fort Wayne                   <named list [1]>
#> 4 Elkhart-Goshen               <named list [1]>
#> 5 Chicago-Naperville-Elgin     <named list [1]>
#> 6 Indianapolis-Carmel-Anderson <named list [1]>
```
