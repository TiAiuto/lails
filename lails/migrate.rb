require '../lails/sqlite_connection_service'
require '../lails/entity_definition_service'
require '../lails/config'

# ここではmigrationのファイルを読み込んで順次適用していく
db = SQLiteConnectionService.new(SQLITE_FILENAME)
