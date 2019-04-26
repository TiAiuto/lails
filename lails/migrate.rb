require '../lails/sqlite_connection_service'
require '../lails/entity_definition_service'
require '../lails/config'

# ここではmigrationのファイルを読み込んで順次適用していく
db     = SQLiteConnectionService.new(SQLITE_FILENAME).db
tables = db.execute("SELECT * FROM sqlite_master")

schema_table_exists = tables.find do |row|
  row[1] == "schema_migrations"
end

unless schema_table_exists
  sql = <<END
  CREATE TABLE schema_migrations(
    version text
  )
END
  db.execute sql
end

puts Dir.glob("#{APP_ROOT}db/migrate/*")
