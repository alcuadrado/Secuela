# encoding: utf-8

require 'mysql'
require_relative 'Table.rb'
require_relative 'ForeignKey.rb'

class Database

  attr_accessor :name

  def initialize(options)
    @tables = {}
    @foreign_keys = []
    @database_handler = options[:database_handler]
    @information_schema_handler = options[:information_schema_handler]
    @name = options[:name]
    get_tables_from_database()
    get_foreing_keys_from_database()
  end

  def each_table
    if block_given?
      @tables.values.each { |table| yield table }
    else    
      @tables.values.each
    end
  end
  
  def add_table(new_table)
    @tables[new_table.name] = new_table
  end
  
  def get_table(table_name)
     @tables[table_name]
  end
  
  def each_foreign_key
    if block_given?
      @foreign_keys.each { |foreign_key| yield foreign_key }
    else    
      @foreign_keys.each
    end
  end
  
  def add_foreign_key(new_foreign_key)
    @foreign_keys.push new_foreign_key
  end

private
  
  def get_tables_from_database
    results = @database_handler.query "SHOW TABLES"
    results.each do |row|
      table = Table.new :database_handler => @database_handler, :name => row[0]
      add_table(table)
    end
  end

  def get_foreing_keys_from_database
    each_table do |table|
      results = @information_schema_handler.query(
        "SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME" + 
        " FROM KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '" + 
        @information_schema_handler.quote(name) + "' AND TABLE_NAME = '" +
        @information_schema_handler.quote(table.name) + 
        "' AND REFERENCED_TABLE_SCHEMA = '" + 
        @information_schema_handler.quote(name) + "'"
      )
      results.each_hash do |row|
        rt = get_table(row["REFERENCED_TABLE_NAME"])
        fk = ForeignKey.new(:key_table => table,
          :key_column => table.get_column(row["COLUMN_NAME"]),
          :referenced_table => rt,
          :referenced_column => rt.get_column(row["REFERENCED_COLUMN_NAME"])
        )
        add_foreign_key(fk)
      end
    end
  end
end
