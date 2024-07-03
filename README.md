# surreal_gleam

[![Package Version](https://img.shields.io/hexpm/v/surreal_gleam)](https://hex.pm/packages/surreal_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/surreal_gleam/)

```sh
gleam add surreal_gleam
```
# Logging in as Root
```gleam
import gleam/io
import gleam/list
import surreal_gleam/sg_engine
import surreal_gleam/types



pub fn main() {
  
  let bearer = sg_engine.root_sign_in("user", "pass")
  let table =
    []
    |> sg_engine.add_field("ArrayOfInts", types.Array(types.Int))
    |> sg_engine.add_field("isActive", types.Boolean)
    |> sg_engine.add_default_field(
      "AlwaysDefaultsToOne",
      types.Int,
      types.DefaultInt(1),
    )
    |> sg_engine.create_table_schemafull("Monster")

  let create_namespace = sg_engine.create_namespace("Test")
  let namespace = sg_engine.use_namespace("Test")
  let create_database = sg_engine.create_database("Test")
  let database = sg_engine.use_database("Test")

  let transaction = case table {
    Ok(types.Table(_table_name, _definition, table)) -> {
      list.append(
        [create_namespace, namespace, create_database, database],
        table,
      )
    }
    Error(x) -> {
      []
    }
  }
  case bearer {
    Ok(token) -> {
      case sg_engine.execute_transaction(transaction, token) {
        Ok(x) -> {
          let _ = io.println(x)
        }
        Error(x) -> {
          let _ = io.println_error(x)
        }
      }
    }
    Error(error) -> {
      let _ = io.println_error(error)
    }
  }
}


```
# creating a schema definition
```gleam
import gleam/io
import gleam/list
import surreal_gleam/sg_engine
import surreal_gleam/types



pub fn main() {
  
  let table =
    []
    |> sg_engine.add_field("ArrayOfInts", types.Array(types.Int))
    |> sg_engine.add_field("isActive", types.Boolean)
    |> sg_engine.add_default_field(
      "AlwaysDefaultsToOne",
      types.Int,
      types.DefaultInt(1),
    )
    |> sg_engine.create_table_schemafull("Monster")


```
# Namespace and Database create/use
```gleam
import gleam/io
import gleam/list
import surreal_gleam/sg_engine
import surreal_gleam/types



pub fn main() {
  
 

  let create_namespace = sg_engine.create_namespace("Test")
  let namespace = sg_engine.use_namespace("Test")
  let create_database = sg_engine.create_database("Test")
  let database = sg_engine.use_database("Test")

  let transaction = case table {
    Ok(types.Table(_table_name, _definition, table)) -> {
      list.append(
        [create_namespace, namespace, create_database, database],
        table,
      )
    }
    Error(x) -> {
      []
    }
  }
  case bearer {
    Ok(token) -> {
      case sg_engine.execute_transaction(transaction, token) {
        Ok(x) -> {
          let _ = io.println(x)
        }
        Error(x) -> {
          let _ = io.println_error(x)
        }
      }
    }
    Error(error) -> {
      let _ = io.println_error(error)
    }
  }
}


```
# Define and execute a transaction
```gleam
import gleam/io
import gleam/list
import surreal_gleam/sg_engine
import surreal_gleam/types



pub fn main() {
  
  let bearer = sg_engine.root_sign_in("user", "pass")

  let table =
    []
    |> sg_engine.add_field("ArrayOfInts", types.Array(types.Int))
    |> sg_engine.add_field("isActive", types.Boolean)
    |> sg_engine.add_default_field(
      "AlwaysDefaultsToOne",
      types.Int,
      types.DefaultInt(1),
    )
    |> sg_engine.create_table_schemafull("Monster") //this function will create a list of statements to create your table, as well as if there is an error at compile time, throw the list of errors to you.

  let create_namespace = sg_engine.create_namespace("Test")
  let namespace = sg_engine.use_namespace("Test")
  let create_database = sg_engine.create_database("Test")
  let database = sg_engine.use_database("Test")

  let transaction = case table {
    Ok(types.Table(_table_name, _definition, table)) -> {
      list.append(
        [create_namespace, namespace, create_database, database],
        table,
      )// I use list.append here becase [..table] is only relevant for adding one list at a time
    }
    Error(x) -> {
      []
    }
  }
  case bearer {
    Ok(token) -> { // if the root successfully logged in then execute the transaction
      case sg_engine.execute_transaction(transaction, token) {
        Ok(x) -> { // print server success json
          let _ = io.println(x)
        }
        Error(x) -> {// print server error json
          let _ = io.println_error(x)
        }
      }
    }
    Error(error) -> {// root log in failed
      let _ = io.println_error(error)
    }
  }
}


```

Further documentation can be found at <https://hexdocs.pm/surreal_gleam>.

## TODO
```sh
|> Finish mapping Surreal Types
|> Finish Table generating code
|> generate {{Model}}.gleam for all tables
|> generate decoders for all tables
|> create basic query DSL
|> create advanced query DSL
|> back_end jobs that run on your database written in gleam?
|> so much more...
```
## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
