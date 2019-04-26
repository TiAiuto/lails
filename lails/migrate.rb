require '../lails/sqlite_connection_service'
require '../lails/entity_definition_service'
require '../lails/config'
require '../lails/rails'

# ここではmigrationのファイルを読み込んで順次適用していく
db          = SQLiteConnectionService.new(SQLITE_FILENAME).db
def_service = EntityDefinitionService.new(db)

unless def_service.table_exists? 'schema_migrations'
  def_service.create_table :schema_migrations do |t|
    t.string :version
  end
end

version_max = db.execute('SELECT MAX(version) FROM schema_migrations')[0][0]

module ActiveRecord
end

class ActiveRecordMigration
  attr_accessor :_def_service

  def create_table(name_symbol, &block)
    @_def_service.create_table(name_symbol, &block)
  end

  def add_column(table_symbol, key_symbol, type_symbol)
    @_def_service.add_column(table_symbol, key_symbol, type_symbol)
  end

  def add_index(table_symbol, key_symbol, options)
    # なくても動くのでいったんpending
  end
end

class ActiveRecord::Migration
  def self.[](number)
    ActiveRecordMigration
  end
end

can_process_migration = false
if version_max.nil?
  can_process_migration = true
  puts "マイグレーション初回実行"
else
  puts "#{version_max} までマイグレーション実行済み"
end

Dir.glob("#{APP_ROOT}db/migrate/*").sort.each do |filename|
  if version_max && !can_process_migration
    puts "#{filename} skipped"
  end
  if version_max && filename.index(version_max.to_s)
    # 特定のバージョン以降のみを処理する場合
    # このファイルの次からは処理してOK
    can_process_migration = true
    next
  end
  if can_process_migration
    puts "#{filename} 処理中"
    classes_before = ActiveRecordMigration.subclasses.dup
    require filename
    next_class                       = (ActiveRecordMigration.subclasses - classes_before).first
    next_class_instance              = next_class.new
    next_class_instance._def_service = def_service
    next_class_instance.change
    current_migration_id = File.basename(filename).split("_")[0]
    puts "#{current_migration_id} DONE"
    db.execute("INSERT INTO schema_migrations (version) VALUES (?) ", current_migration_id)
  end
end
