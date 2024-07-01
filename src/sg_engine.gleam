import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/http/response.{Response}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import types.{
  type DefaultFieldType, type EmittedLines, type Entity, Array, Boolean,
  DateTime, Decimal, Float, Int, None, String,
}

fn build_request(base: String, endpoint: String, method: http.Method) {
  // Prepare a HTTP request record
  let assert Ok(request) = request.to(base <> endpoint)

  request.set_method(request, method)
}

fn with_token(request: request.Request(String), token: String) {
  request |> request.prepend_header("Authorization", "Bearer " <> token)
}

fn with_header(request: request.Request(String), key: String, value: String) {
  // Prepare a HTTP request record
  request |> request.prepend_header(key, value)
  // Send the HTTP request to the server
}

fn execute_request(
  request: request.Request(String),
) -> Result(response.Response(String), hackney.Error) {
  request |> hackney.send
}

pub fn root_sign_in(
  username: String,
  password: String,
) -> Result(String, String) {
  let error_msg = "Failed to Sign In!"
  let request =
    build_request("http://localhost:8000/", "signin", http.Post)
    |> request.prepend_header("Accept", "application/json")
    |> request.set_body(
      "{ \"user\":\"" <> username <> "\", \"pass\":\"" <> password <> "\"}",
    )

  let response = execute_request(request)

  case response {
    Ok(resp) -> {
      case resp.status {
        200 -> {
          let token_json =
            resp.body
            |> string.replace("}", "")
            |> string.replace("\"", "")
            |> string.split(",")
            |> list.filter(fn(x) { x |> string.contains("token") })

          case token_json |> list.first {
            Ok(x) -> {
              case string.split(x, ":") |> list.last {
                Ok(x) -> Ok(x)
                Error(_) -> Error(error_msg)
              }
            }
            _ -> {
              Error(error_msg)
            }
          }
        }
        _ -> {
          Error(error_msg)
        }
      }
    }
    Error(_) -> {
      Error(error_msg)
    }
  }
}

pub fn exec(lines: EmittedLines) {
  lines
  |> list.each(fn(res) {
    case res {
      Ok(x) -> io.println(x)
      Error(x) -> io.print_error(x)
    }
  })
}

pub fn execute_transaction(
  statements: List(Result(String, String)),
) -> List(Result(String, String)) {
  let generated_lines =
    [Ok("BEGIN TRANSACTION;")]
    |> list.append(statements)
    |> list.append([Ok("COMMIT TRANSACTION;")])
    |> iterate

  let errors =
    generated_lines
    |> list.filter(fn(a) {
      case a {
        Error(_) -> True
        _ -> False
      }
    })

  case list.length(errors) {
    x if x > 0 -> {
      errors
    }
    _ -> {
      generated_lines
      |> list.map(fn(x) {
        case x {
          Ok(val) -> {
            Ok(val)
          }
          _ -> Ok("")
        }
      })
    }
  }
}

fn inner_iterate(
  statements: List(Result(String, String)),
  acc: List(Result(String, String)),
) {
  case statements {
    [head, ..rest] -> {
      case head {
        Ok(x) -> {
          inner_iterate(rest, [Ok(x), ..acc])
        }
        Error(x) -> {
          inner_iterate(rest, [Error(x), ..acc])
        }
      }
    }
    [] -> acc
  }
}

fn iterate(
  statements: List(Result(String, String)),
) -> List(Result(String, String)) {
  inner_iterate(statements |> list.reverse, [])
}

pub fn create_database(name: String) -> Result(String, String) {
  Ok("DEFINE DATABASE " <> name <> ";")
}

pub fn create_namespace(name: String) -> Result(String, String) {
  Ok("DEFINE NAMESPACE " <> name <> ";")
}

pub fn use_namespace(name: String) -> Result(String, String) {
  Ok("USE NAMESPACE " <> name <> ";")
}

pub fn use_database(name: String) -> Result(String, String) {
  Ok("USE db " <> name <> ";")
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

pub fn emit_fields(x: Entity, table: String) -> types.EmittedLines {
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
              Int -> "int"
              Float -> "float"
              Decimal -> "decimal"
              String -> "string"
              Boolean -> "bool"
              DateTime -> "datetime"
              _ -> ""
            }
            "array<" <> data_type <> ">"
          }
          Int -> "int"
          Float -> "float"
          Decimal -> "decimal"
          String -> "string"
          Boolean -> "bool"
          DateTime -> "datetime"
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
