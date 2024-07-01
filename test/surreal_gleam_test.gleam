import gleam/io
import gleam/list
import gleeunit
import gleeunit/should
import sg_engine
import types

pub fn main() {
  gleeunit.main()
}

pub fn create_monster_table_test() {
  []
  |> sg_engine.add_field("FavoriteFoods", types.Array(types.Int))
  |> sg_engine.add_field("IsVicious", types.Boolean)
  |> sg_engine.add_default_field(
    "AlwaysDefaultsToOne",
    types.Int,
    types.DefaultInt(1),
  )
  |> sg_engine.create_table_schemafull("Monster")
  |> list.map(fn(x) { should.be_ok(x) })
}

pub fn create_monster_table_fail_test() {
  []
  |> sg_engine.add_field("FavoriteFoods", types.Array(types.Int))
  |> sg_engine.add_field("IsVicious", types.Boolean)
  |> sg_engine.add_default_field(
    "AlwaysDefaultsToOne",
    types.Int,
    types.DefaultString("Cow"),
  )
  |> sg_engine.create_table_schemafull("Monster")
  |> list.index_map(fn(item, count) {
    case count {
      3 -> {
        should.be_error(item)
      }
      _ -> {
        should.be_ok(item)
      }
    }
  })
}

pub fn create_monster_transaction_test() {
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

  sg_engine.execute_transaction(transaction)
  |> list.map(fn(x) { should.be_ok(x) })
}
