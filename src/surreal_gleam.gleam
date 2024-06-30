import gleam/io
import sg_engine
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
