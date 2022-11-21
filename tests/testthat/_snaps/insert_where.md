# Check method dispatch works

    Code
      insert_where(config_where_chr, to_insert)
    Output
      [1] "content.name = 'test' AND content.name = 'test_new'"

---

    Code
      insert_where(config_where_list, to_insert)
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
      insert_where(config_where_df, to_insert)
    Output
          table field values
      1 content  name   test

# Check `replace = FALSE`

    Code
      insert_where(config_where_list, to_insert, replace = FALSE)
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
      insert_where(NULL, to_insert)
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
      insert_where(list(), to_insert)
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
      insert_where(data.frame(), to_insert)
    Output
          table field   values
      1 content  name test_new

# Insert single game

    [
      {
        "table": "content",
        "field": "Id",
        "values": "dummy"
      }
    ]

# Can compose after `insert_where()`

    "WHERE content.name = 'test_new'"

