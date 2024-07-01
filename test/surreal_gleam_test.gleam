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
  |> should.be_ok
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
  |> should.be_error
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

  let transaction = case table {
    Ok(types.Table(table_name, defintion, table)) -> {
      list.append(
        [create_namespace, namespace, create_database, database],
        table,
      )
    }
    Error(x) -> {
      []
    }
  }

  sg_engine.execute_transaction(transaction, "")
}
