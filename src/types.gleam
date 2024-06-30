pub type Geometry {
  Point
  LineString
  Polygon
  MultiPoint
  MultiLineString
  MultiPolygon
  GeometryCollection
}

pub type FieldType {
  Array(FieldType)
  Boolean
  RecordID
  None
  Null
  Int
  Float
  String
  Datetime
  Object(List(FieldType))
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
  Table(table_name: String, entity_definition: Entity)
}

pub type EmittedEntity =
  List(Result(String, String))
