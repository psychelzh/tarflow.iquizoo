# Correctly combine `game_info`

    Code
      search_games(NULL, query_file = "dummy/test.sql")
    Output
      # A tibble: 1 x 6
        game_id        game_name game_name_en    game_name_abbr prep_fun_name prep_fun
        <chr>          <chr>     <chr>           <chr>          <chr>         <list>  
      1 1813dfbd-f61e~ 方向临摹  Judgment of Li~ JLO            jlo           <sym>   

---

    Code
      search_games(NULL, known_only = FALSE, query_file = "dummy/test.sql")
    Output
      # A tibble: 2 x 5
        game_id              game_name game_name_en       game_name_abbr prep_fun_name
        <chr>                <chr>     <chr>              <chr>          <chr>        
      1 1813dfbd-f61e-47f5-~ 方向临摹  Judgment of Line ~ JLO            jlo          
      2 test                 <NA>      <NA>               <NA>           <NA>         

