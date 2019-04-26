require '../lails/sqlite_connection_service'
require '../lails/entity_definition_service'
require '../lails/config'

# ここではmigrationのファイルを読み込んで順次適用していく
db          = SQLiteConnectionService.new(SQLITE_FILENAME).db
def_service = EntityDefinitionService.new(db)

unless def_service.table_exists? 'schema_migr
ations'
  def_service.create_table 'schema_migrations', [
    { name: 'version', type: 'string' }
  ]
end

puts Dir.glob("#{APP_ROOT}db/migrate/*")
