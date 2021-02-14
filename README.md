
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ebtools

<!-- badges: start -->

[![R-CMD-check](https://github.com/ercbk/ebtools/workflows/R-CMD-check/badge.svg)](https://github.com/ercbk/ebtools/actions)
<!-- badges: end -->

Eric’s Data Science Toolbox

## Installation

Install from [GitHub](https://github.com/ercbk/ebtools) with:

``` r
# install.packages("remotes")
remotes::install_github("ercbk/ebtools")
```

## What’s in it

<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#pbbcoxmpgv .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#pbbcoxmpgv .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#pbbcoxmpgv .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#pbbcoxmpgv .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#pbbcoxmpgv .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#pbbcoxmpgv .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#pbbcoxmpgv .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#pbbcoxmpgv .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#pbbcoxmpgv .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#pbbcoxmpgv .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#pbbcoxmpgv .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#pbbcoxmpgv .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#pbbcoxmpgv .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#pbbcoxmpgv .gt_from_md > :first-child {
  margin-top: 0;
}

#pbbcoxmpgv .gt_from_md > :last-child {
  margin-bottom: 0;
}

#pbbcoxmpgv .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#pbbcoxmpgv .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#pbbcoxmpgv .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#pbbcoxmpgv .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#pbbcoxmpgv .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#pbbcoxmpgv .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#pbbcoxmpgv .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#pbbcoxmpgv .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#pbbcoxmpgv .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#pbbcoxmpgv .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#pbbcoxmpgv .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#pbbcoxmpgv .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#pbbcoxmpgv .gt_left {
  text-align: left;
}

#pbbcoxmpgv .gt_center {
  text-align: center;
}

#pbbcoxmpgv .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#pbbcoxmpgv .gt_font_normal {
  font-weight: normal;
}

#pbbcoxmpgv .gt_font_bold {
  font-weight: bold;
}

#pbbcoxmpgv .gt_font_italic {
  font-style: italic;
}

#pbbcoxmpgv .gt_super {
  font-size: 65%;
}

#pbbcoxmpgv .gt_footnote_marks {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="pbbcoxmpgv" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;"><table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Function</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Description</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Complementary Packages</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <td colspan="3" class="gt_group_heading">Time Series</td>
    </tr>
    <tr>
      <td class="gt_row gt_left">create_dtw_grids</td>
      <td class="gt_row gt_left">Creates a nested, parameter grid list.</td>
      <td class="gt_row gt_left">dtw, dtwclust</td>
    </tr>
    <tr>
      <td class="gt_row gt_left">dtw_dist_gridsearch</td>
      <td class="gt_row gt_left">Performs a gridsearch using a list of parameter grids and a list of distance functions</td>
      <td class="gt_row gt_left">dtw, dtwclust</td>
    </tr>
    <tr>
      <td class="gt_row gt_left">test_fable_resids</td>
      <td class="gt_row gt_left">Checks residuals of multiple fable models for autocorrelation using the Ljung-Box test</td>
      <td class="gt_row gt_left">fable</td>
    </tr>
    <tr>
      <td class="gt_row gt_left">test_lm_resids</td>
      <td class="gt_row gt_left">Checks residuals of multiple lm models for autocorrelation using Breusch-Godfrey and Durbin-Watson tests.</td>
      <td class="gt_row gt_left"></td>
    </tr>
    <tr>
      <td class="gt_row gt_left">prewhitened_ccf</td>
      <td class="gt_row gt_left">Prewhitens time series, calculates cross-correlation coefficients, and returns statistically significant values.</td>
      <td class="gt_row gt_left"></td>
    </tr>
    <tr class="gt_group_heading_row">
      <td colspan="3" class="gt_group_heading">Visualization</td>
    </tr>
    <tr>
      <td class="gt_row gt_left">to_js_array</td>
      <td class="gt_row gt_left">Creates js array column.</td>
      <td class="gt_row gt_left">dataui</td>
    </tr>
  </tbody>
  
  
</table></div>
