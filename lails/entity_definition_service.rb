class ChangeMigrationBuilder
  attr_reader :keys

  def initialize
    @keys = []
  end

  def string(name_symbol)
    @keys << { name: name_symbol.to_s, type: :string }
  end

  def timestamps
    string(:created_at)
    string(:updated_at)
  end
end

class EntityDefinitionService
  def initialize(db)
    @db = db
  end

  # ToDo: SQLインジェクション対策

  def create_table(name_symbol, &block)
    change_builder = ChangeMigrationBuilder.new
    block.call(change_builder)
    keys = ["id INTEGER PRIMARY KEY"] + change_builder.keys.map do |item|
      "#{item[:name]} #{item[:type]}"
    end
    sql  = <<END
  CREATE TABLE #{name_symbol.to_s} (
    #{keys.join(", ")}
  )
END
    puts sql
    @db.execute sql
  end

  def create_table_without_id(name_symbol, &block)
    change_builder = ChangeMigrationBuilder.new
    block.call(change_builder)
    keys = change_builder.keys.map do |item|
      "#{item[:name]} #{item[:type]}"
    end
    sql  = <<END
  CREATE TABLE #{name_symbol.to_s} (
    #{keys.join(", ")}
  )
END
    puts sql
    @db.execute sql
  end

  def add_column(table_symbol, key_symbol, type_symbol)
    sql = "ALTER TABLE #{table_symbol.to_s} ADD COLUMN #{key_symbol.to_s} #{type_symbol.to_s};"
    puts sql
    @db.execute sql
  end

  def add_index

  end

  def get_def

  end

  def table_exists?(name)
    tables = @db.execute("SELECT * FROM sqlite_master")
    !!tables.find do |row|
      row[1] == "schema_migrations"
    end
  end
end