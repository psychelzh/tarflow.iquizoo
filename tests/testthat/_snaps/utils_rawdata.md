# Basic situation of `wrange_data()`

    Code
      data_wrangled
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `meta`, `data`
      Columns: 7
      Primary keys: 2
      Foreign keys: 1

---

    Code
      dm::dm_get_tables(data_wrangled)
    Output
      $meta
      # A tibble: 2 x 4
          .id user_id game_id game_time 
        <int>   <int> <chr>   <chr>     
      1     1       1 A       1990-01-01
      2     2       2 B       1990-01-01
      
      $data
      # A tibble: 10 x 3
           .id     a     b
         <int> <int> <int>
       1     1     1     1
       2     1     2     2
       3     1     3     3
       4     1     4     4
       5     1     5     5
       6     2     1     1
       7     2     2     2
       8     2     3     3
       9     2     4     4
      10     2     5     5
      

# Remove duplicates in `wrangle_data()`

    Code
      parsed_dup
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `meta`, `data`
      Columns: 5
      Primary keys: 2
      Foreign keys: 1

---

    Code
      dm::dm_get_tables(parsed_dup)
    Output
      $meta
      # A tibble: 2 x 2
          .id user_id
        <int>   <int>
      1     1       1
      2     2       2
      
      $data
      # A tibble: 8 x 3
          .id     a     b
        <int> <int> <int>
      1     1     1     1
      2     1     2     2
      3     1     3     3
      4     1     4     4
      5     1     5     5
      6     2     2     1
      7     2     3     2
      8     2     4     3
      

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
      

