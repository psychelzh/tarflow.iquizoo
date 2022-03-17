# Basic situation in `preproc_data()`

    -- Metadata --------------------------------------------------------------------
    Tables: `meta`, `indices`
    Columns: 5
    Primary keys: 2
    Foreign keys: 1

---

    $meta
    # A tibble: 2 x 2
        .id user_id
      <int>   <int>
    1     1       1
    2     2       2
    
    $indices
    # A tibble: 6 x 3
        .id index_name     score
      <int> <chr>          <dbl>
    1     1 mean_pumps       NaN
    2     1 mean_pumps_raw     1
    3     1 num_explosion      1
    4     2 mean_pumps         1
    5     2 mean_pumps_raw     1
    6     2 num_explosion      0
    

# Complex dplyr verbs in `preproc_data()`

    -- Metadata --------------------------------------------------------------------
    Tables: `meta`, `indices`
    Columns: 5
    Primary keys: 2
    Foreign keys: 1

---

    $meta
    # A tibble: 1 x 2
        .id user_id
      <int>   <dbl>
    1     1       1
    
    $indices
    # A tibble: 7 x 3
        .id index_name      score
      <int> <chr>           <dbl>
    1     1 nc           8   e+ 0
    2     1 mrt          1.53e+ 3
    3     1 rtsd         3.26e+ 2
    4     1 dprime      -4.60e- 1
    5     1 c           -5.55e-17
    6     1 commissions  6   e+ 0
    7     1 omissions    6   e+ 0
    

