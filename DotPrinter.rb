# encoding: utf-8

class DotPrinter

  def initialize(output_file = $stdout)
    @output_file = output_file
  end

  def print_database(database)
    output_file.puts "digraph {"
    
    output_file.puts "\tfontname = \"Bitstream Vera Sans\""
    output_file.puts "\tfontsize = 8"
    
    output_file.puts "\tnode ["
    output_file.puts "\t\tfontname = \"Bitstream Vera Sans\""
    output_file.puts "\t\tfontsize = 8"
    output_file.puts "\t\tshape = \"record\""
    output_file.puts "\t]"
    
    output_file.puts "\tedge ["
    output_file.puts "\t\tfontname = \"Bitstream Vera Sans\""
    output_file.puts "\t\tfontsize = 8"
    output_file.puts "\t]"
    
    database.each_table { |table| print_table(table) }
    
    database.each_foreign_key { |fk| print_foreign_key(fk) }
    
    output_file.puts "}"
  end

private

  attr_reader :output_file

  def print_table(table)
    output_file.puts "\t#{table.name} ["
    output_file.print "\t\tlabel = \"{#{table.name}|"
    table.each_column { |column| print_column(column) }
    output_file.puts "}\""
    output_file.puts "\t]"
  end
  
  def print_column(column)
    output_file.print "+ #{column.name} : #{column.type}\\l"
  end
  
  def print_foreign_key(foreign_key)
    output_file.puts "\t #{foreign_key.key_table.name} -> #{foreign_key.referenced_table.name}"
  end

end
