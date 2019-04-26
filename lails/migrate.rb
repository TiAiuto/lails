require '../lails/sqlite_connection_service'
require '../lails/entity_definition_service'
require '../lails/config'
require '../lails/rails'

# ここではmigrationのファイルを読み込んで順次適用していく
db          = SQLiteConnectionService.new(SQLITE_FILENAME).db
def_service = EntityDefinitionService.new(db)

unless def_service.table_exists? 'schema_migrations'
  def_service.create_table 'schema_migrations', [
    { name: 'version', type: 'string' }
  ]
end

version_max = db.execute('SELECT MAX(version) FROM schema_migrations')[0][0] || 0

module ActiveRecord
end

class ActiveRecordMigration
end

class ActiveRecord::Migration
  def self.[](number)
    ActiveRecordMigration
  end
end

Dir.glob("#{APP_ROOT}db/migrate/*").each do |filename|
  require filename
end

puts ActiveRecordMigration.subclasses