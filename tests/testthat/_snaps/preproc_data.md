# Basic situation in `preproc_data()`

    Code
      dm_indices
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `meta`, `indices`
      Columns: 6
      Primary keys: 2
      Foreign keys: 1

---

    Code
      dm::dm_get_tables(dm_indices)
    Output
      $meta
      # A tibble: 2 x 2
          .id user_id
        <int>   <int>
      1     1       1
      2     2       2
      
      $indices
      # A tibble: 2 x 4
          .id mean_pumps mean_pumps_raw num_explosion
        <int>      <dbl>          <dbl>         <int>
      1     1        NaN              1             1
      2     2          1              1             0
      

# Complex dplyr verbs in `preproc_data()`

    Code
      dm_indices
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `meta`, `indices`
      Columns: 10
      Primary keys: 2
      Foreign keys: 1

---

    Code
      dm::dm_get_tables(dm_indices)
    Output
      $meta
      # A tibble: 1 x 2
          .id user_id
        <int>   <dbl>
      1     1       1
      
      $indices
      # A tibble: 1 x 8
          .id    nc   mrt  rtsd dprime         c commissions omissions
        <int> <int> <dbl> <dbl>  <dbl>     <dbl>       <int>     <int>
      1     1     8 1194.  523. -0.460 -5.55e-17           6         6
      

