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
      data_wrangled$meta
    Output
      # A tibble: 2 x 4
          .id user_id game_id game_time 
        <int>   <int> <chr>   <chr>     
      1     1       1 A       1990-01-01
      2     2       2 B       1990-01-01

---

    Code
      data_wrangled$data
    Output
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
      parsed_dup$meta
    Output
      # A tibble: 2 x 2
          .id user_id
        <int>   <int>
      1     1       1
      2     2       2

---

    Code
      parsed_dup$data
    Output
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
      dm_indices$meta
    Output
      # A tibble: 2 x 2
          .id user_id
        <int>   <int>
      1     1       1
      2     2       2

---

    Code
      dm_indices$indices
    Output
      # A tibble: 2 x 4
          .id mean_pumps mean_pumps_raw num_explosion
        <int>      <dbl>          <dbl>         <int>
      1     1        NaN              1             1
      2     2          1              1             0

