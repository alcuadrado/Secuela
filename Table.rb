# encoding: utf-8

require 'mysql'
require_relative 'Column.rb'

class Table

  attr_accessor :name

  def initialize(options)
    @columns = {}
    @database_handler = options[:database_handler]
    @information_schema_handler = options[:information_schema_handler]
    self.name = options[:name]
    get_columns_from_database()
  end
  
  def each_column
    if block_given?
      @columns.values.each { |column| yield column }
    else    
      @columns.values.each
    end
  end
  
  def add_column(new_column)
    @columns[new_column.name] = new_column
  end
  
  def get_column(column_name)
    @columns[column_name]
  end

private

  def get_columns_from_database
    results = @database_handler.query(
      "DESCRIBE `" + @database_handler.quote(self.name) + "`"
    )
    results.each_hash do |row|
      column = Column.new :name => row["Field"], :type => row["Type"]
      add_column column
    end
  end

end
