require 'sqlite3'

class SQLiteConnectionService
  def initialize(filename)
    SQLite3::Database.new(filename)
  end
end