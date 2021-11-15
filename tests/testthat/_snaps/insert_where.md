# Check method dispatch works

    [
      {
        "table": "content"
      }
    ]

---

    Code
      insert_where(config_where, list(table = "content", values = 1))
    Output
      # A tibble: 1 x 2
        table   values   
        <chr>   <list>   
      1 content <chr [1]>

# Check `replace = FALSE`

    [
      {
        "table": "content",
        "field": "name",
        "values": "test"
      },
      {
        "table": "content"
      }
    ]

