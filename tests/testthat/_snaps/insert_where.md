# Check method dispatch works

    Code
      insert_where(config_where, list(table = "content"))
    Output
      [[1]]
      [[1]]$table
      [1] "content"
      
      

---

    Code
      insert_where(config_where, list(table = "content", values = 1))
    Output
      # A tibble: 1 x 2
        table   values   
        <chr>   <list>   
      1 content <chr [1]>

# Check `replace = FALSE`

    Code
      insert_where(config_where, list(table = "content"), replace = FALSE)
    Output
      [[1]]
      [[1]]$table
      [1] "content"
      
      [[1]]$field
      [1] "name"
      
      [[1]]$values
      [1] "test"
      
      
      [[2]]
      [[2]]$table
      [1] "content"
      
      

