# Basic situation in `preproc_data()`

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["user_id", "index_name", "score"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2]
        },
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["tbl_df", "tbl", "data.frame"]
        }
      },
      "value": [
        {
          "type": "integer",
          "attributes": {},
          "value": [1, 2]
        },
        {
          "type": "character",
          "attributes": {},
          "value": ["nhit", "nhit"]
        },
        {
          "type": "double",
          "attributes": {},
          "value": ["NaN", 1]
        }
      ]
    }

# Deal with `NULL` in parsed data

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["user_id", "index_name", "score"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2]
        },
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["tbl_df", "tbl", "data.frame"]
        }
      },
      "value": [
        {
          "type": "integer",
          "attributes": {},
          "value": [1, 3]
        },
        {
          "type": "character",
          "attributes": {},
          "value": ["nhit", "nhit"]
        },
        {
          "type": "double",
          "attributes": {},
          "value": ["NaN", 1]
        }
      ]
    }

# Can deal with mismatch column types in raw data

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["user_id", "index_name", "score"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3]
        },
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["tbl_df", "tbl", "data.frame"]
        }
      },
      "value": [
        {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3]
        },
        {
          "type": "character",
          "attributes": {},
          "value": ["nhit", "nhit", "nhit"]
        },
        {
          "type": "double",
          "attributes": {},
          "value": ["NaN", 2, 3]
        }
      ]
    }

