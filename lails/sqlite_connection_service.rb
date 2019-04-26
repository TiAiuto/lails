require 'sqlite3'

class SQLiteConnectionService
  attr_reader :db
  def initialize(filename)
    @db = SQLite3::Database.new(filename)
  end
end