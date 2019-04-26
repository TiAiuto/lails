class EntityDefinitionService
  def initialize(db)
    @db = db
  end

  # ToDo: SQLインジェクション対策

  def create_table(name, keys = [])
    key_defs = keys.map do |item|
      "#{item[:name]} #{item[:type]}"
    end.join(", ")
    sql = <<END
  CREATE TABLE #{name} (
    #{key_defs}
  )
END
    puts sql
    @db.execute sql
  end

  def add_column

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