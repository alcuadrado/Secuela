# encoding: utf-8

class ForeignKey

  attr_reader :key_table, :key_column, :referenced_table, :referenced_column

  def initialize(options)
    @key_table = options[:key_table]
    @key_column = options[:key_column]
    @referenced_table = options[:referenced_table]
    @referenced_column = options[:referenced_column]
  end

end
