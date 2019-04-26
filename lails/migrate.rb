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

version_max = db.execute('SELECT MAX(version) FROM schema_migrations')[0][0]

module ActiveRecord
end

class ActiveRecordMigration
end

class ActiveRecord::Migration
  def self.[](number)
    ActiveRecordMigration
  end
end

can_process_migration = false
if version_max.nil?
  can_process_migration = true
end

Dir.glob("#{APP_ROOT}db/migrate/*").sort.each do |filename|
  if version_max && (filename.index version_max)
    # 特定のバージョン以降のみを処理する場合
    # このファイルの次からは処理してOK
    can_process_migration = true
  end
  puts filename
  if can_process_migration
    classes_before = ActiveRecordMigration.subclasses.dup
    require filename
    next_class = (ActiveRecordMigration.subclasses - classes_before).first
    # next_class.new.change do
    #
    # end
  end
end
