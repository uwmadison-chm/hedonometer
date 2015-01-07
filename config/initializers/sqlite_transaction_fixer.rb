# -*- encoding : utf-8 -*-
# Forces SQLite transactions to be immediate, and hence block when waiting
# for a lock on the database file.
# I know, use a real goddamn database.

module ActiveRecord
  module ConnectionAdapters
    class SQLiteAdapter < AbstractAdapter
      def begin_db_transaction
        log('begin immediate transaction', nil) { @connection.transaction(:immediate) }
      end
    end
  end
end