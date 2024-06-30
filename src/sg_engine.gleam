import gleam/int
import gleam/io
import gleam/list
import types.{
  type DefaultFieldType, type EmittedEntity, type Entity, Array, Boolean, Int,
  None, String,
}

pub fn exec(lines: EmittedEntity) {
  lines
  |> list.map(fn(res) {
    case res {
      Ok(x) -> io.println(x)
      Error(x) -> io.print_error(x)
    }
  })
}

pub fn create_table_schemafull(
  entity_definition: Entity,
  name: String,
) -> List(Result(String, String)) {
  //does a table creation

  emit_fields(
    entity_definition
      |> list.append([
        #("", None, Ok("DEFINE TABLE IF NOT EXISTS " <> name <> " schemafull;")),
      ]),
    name,
  )
}

pub fn create_table_schemaless(
  entity_definition: Entity,
  name: String,
) -> List(Result(String, String)) {
  //does a table creation

  emit_fields(
    entity_definition
      |> list.append([
        #("", None, Ok("DEFINE TABLE IF NOT EXISTS " <> name <> " schemaless;")),
      ]),
    name,
  )
}

pub fn emit_fields(x: Entity, table: String) -> EmittedEntity {
  x
  |> list.reverse
  |> list.map(fn(entity) {
    case entity {
      #("", None, Ok(x)) -> {
        Ok(x)
      }
      #(name, field_type, Ok(default)) -> {
        let ft = case field_type {
          Array(x) -> {
            let data_type = case x {
              Int -> "Int"
              _ -> ""
            }
            "array<" <> data_type <> ">"
          }
          Boolean -> "Bool"
          Int -> "Int"
          _ -> io.debug(name <> " failed")
        }
        Ok(
          "DEFINE FIELD "
          <> name
          <> " ON TABLE "
          <> table
          <> " TYPE "
          <> ft
          <> " "
          <> default
          <> ";",
        )
      }
      #(field, _, Error(_)) -> {
        Error("FAILED::: DEFINE FIELD FOR " <> field)
      }
    }
  })
}

pub fn add_field(
  e: Entity,
  field: String,
  field_type: types.FieldType,
) -> Entity {
  [#(field, field_type, Ok("")), ..e]
}

pub fn add_default_field(
  e: Entity,
  field: String,
  field_type: types.FieldType,
  d: DefaultFieldType,
) -> Entity {
  let res = case field_type, d {
    types.String, types.DefaultString(x) -> Ok("\"" <> x <> "\"")
    types.Int, types.DefaultInt(x) -> Ok(int.to_string(x))
    _, _ ->
      Error(
        "Field: "
        <> field
        <> " does not support the supplied default value for its type",
      )
  }

  let fullfield = case res {
    Ok(x) -> #(field, field_type, Ok("Default " <> x))
    Error(x) -> #(field, field_type, Error(x))
  }

  [fullfield, ..e]
}

pub fn generate(e: Entity) {
  io.debug(e)
}
