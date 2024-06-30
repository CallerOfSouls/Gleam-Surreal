# surreal_gleam

[![Package Version](https://img.shields.io/hexpm/v/surreal_gleam)](https://hex.pm/packages/surreal_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/surreal_gleam/)

```sh
gleam add surreal_gleam
```
```gleam
import gleam/io
import gleam/list
import surreal_gleam/sg_engine
import surreal_gleam/types

pub fn main() {
  let table =
    []
    |> sg_engine.add_field("FavoriteFoods", types.Array(types.Int))
    |> sg_engine.add_field("IsVicious", types.Boolean)
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

  let transaction =
    list.append([create_namespace, namespace, create_database, database], table)
  io.debug(transaction)
  sg_engine.execute_transaction(transaction)
  |> list.each(fn(x) {
    case x {
      Ok(x) -> io.println(x)
      _ -> io.print("")
    }
  })
}


```

Further documentation can be found at <https://hexdocs.pm/surreal_gleam>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
