# Check method dispatch works

    [
      {
        "table": "content",
        "field": "name",
        "values": "test_new"
      }
    ]

---

    Code
      insert_where(config_where, list(table = "content", field = "name", values = "test_new"))
    Output
      # A tibble: 1 x 3
        table   field values   
        <chr>   <chr> <list>   
      1 content name  <chr [1]>

# Check `replace = FALSE`

    [
      {
        "table": "content",
        "field": "name",
        "values": "test"
      },
      {
        "table": "content",
        "field": "name",
        "values": "test_new"
      }
    ]

# Works with empty old

    [
      {
        "table": "content",
        "field": "name",
        "values": "test_new"
      }
    ]

---

    Code
      insert_where(data.frame(), list(table = "content", field = "name", values = "test_new"))
    Output
      # A tibble: 1 x 3
        table   field values   
        <chr>   <chr> <list>   
      1 content name  <chr [1]>

