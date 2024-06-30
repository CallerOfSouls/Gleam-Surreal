import gleam/io
import gleam/list
import gleeunit
import gleeunit/should
import sg_engine
import types

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
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
  |> list.map(fn(x) {
    let _ = io.debug(x)
    should.be_ok(x)
  })
  io.debug("")
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
    let _ = io.debug(item)
    case count {
      3 -> {
        should.be_error(item)
      }
      _ -> {
        should.be_ok(item)
      }
    }
  })
  io.debug("")
}
