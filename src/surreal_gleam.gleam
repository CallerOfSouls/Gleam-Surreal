import gleam/io
import gleam/list
import sg_engine
import types

pub fn main() {
  let bearer = sg_engine.root_sign_in("Me", "123")
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
    Ok(types.Table(_table_name, _defintion, table)) -> {
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
