# Check method dispatch works

    Code
      insert_where(config_where, list(table = "content", field = "name", values = "test_new"))
    Output
      [[1]]
      [[1]]$table
      [1] "content"
      
      [[1]]$field
      [1] "name"
      
      [[1]]$values
      [1] "test_new"
      
      

---

    Code
      insert_where(config_where, list(table = "content", field = "name", values = "test_new"))
    Output
      # A tibble: 1 x 3
        table   field values   
        <chr>   <chr> <list>   
      1 content name  <chr [1]>

# Check `replace = FALSE`

    Code
      insert_where(config_where, list(table = "content", field = "name", values = "test_new"),
      replace = FALSE)
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
      
      [[2]]$field
      [1] "name"
      
      [[2]]$values
      [1] "test_new"
      
      

# Works with empty old

    Code
      insert_where(NULL, list(table = "content", field = "name", values = "test_new"))
    Output
      [[1]]
      [[1]]$table
      [1] "content"
      
      [[1]]$field
      [1] "name"
      
      [[1]]$values
      [1] "test_new"
      
      

---

    Code
      insert_where(list(), list(table = "content", field = "name", values = "test_new"))
    Output
      [[1]]
      [[1]]$table
      [1] "content"
      
      [[1]]$field
      [1] "name"
      
      [[1]]$values
      [1] "test_new"
      
      

---

    Code
      insert_where(data.frame(), list(table = "content", field = "name", values = "test_new"))
    Output
      # A tibble: 1 x 3
        table   field values   
        <chr>   <chr> <list>   
      1 content name  <chr [1]>

