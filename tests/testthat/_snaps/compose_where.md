# Works for all the class types

    "WHERE content.name = 'test'"

# Works for multiple values

    "WHERE content.name IN ('test1', 'test2')"

# Can compose after `insert_where()`

    "WHERE content.name = 'test_new'"

