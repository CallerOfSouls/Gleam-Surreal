# surreal_gleam

[![Package Version](https://img.shields.io/hexpm/v/surreal_gleam)](https://hex.pm/packages/surreal_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/surreal_gleam/)

```sh
gleam add surreal_gleam
```
```gleam
import surreal_gleam/sg_engine
import types

pub fn main() {
  []
  |> sg_engine.add_field("FavoriteFoods", types.Array(types.Int))
  |> sg_engine.add_field("IsVicious", types.Boolean)
  |> sg_engine.add_default_field(
    "AlwaysDefaultsToOne",
    types.Int,
    types.DefaultInt(1),
  )
  |> sg_engine.create_table_schemafull("Monster")
  |> sg_engine.exec()
}

```

Further documentation can be found at <https://hexdocs.pm/surreal_gleam>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
