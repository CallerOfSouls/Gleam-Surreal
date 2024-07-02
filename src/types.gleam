pub type GeometryType {
  Feature
  Point
  LineString
  Polygon
  MultiPoint
  MultiLine
  MultiPolygon
  Collection
}

pub type FieldType {
  Array(FieldType)
  Boolean
  None
  Null
  Int
  Float
  Decimal
  String
  DateTime
  Record
  Geometry(GeometryType)
  Object
  Option(FieldType)
}

pub type DefaultFieldType {
  DefaultInt(val: Int)
  DefaultString(val: String)
  DefaultArray(val: List(DefaultFieldType))
  DefaultNone
}

pub type Field =
  #(String, FieldType, Result(String, String))

pub type Entity =
  List(Field)

pub type TableEntity {
  Table(table_name: String, definition: Entity, code_gen: EmittedLines)
}

pub type EmittedLines =
  List(Result(String, String))
