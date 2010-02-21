# encoding: utf-8

require 'optparse'
require 'tempfile'
require 'etc'
require_relative 'Database'
require_relative 'DotPrinter'

class Boosttrap
  
  def initialize
  end
  
  def run
    parse_options()

    dbh = Mysql.real_connect(@host, @user, @password, @database)
    ish = Mysql.real_connect(@host, @user, @password, "information_schema")
    db = Database.new(
      :database_handler => dbh,
      :information_schema_handler => ish, 
      :name => @database
    )
    
    @output_file = File.open(@output_file, "w") unless @output_file == $stdout
    
    if @format != "dot" then
      tf = Tempfile.new("mysql2uml")
      printer = DotPrinter.new tf
      printer.print_database db
      tf.flush
      if @output_file == $stdout then
        exec("dot -T png #{tf.path}")
      else
        exec("dot -T png -o #{@output_file.path} #{tf.path}")
      end
      tf.close(true)
    else
      printer = DotPrinter.new @output_file
      printer.print_database db
    end
  end

private

  def parse_options
    opts = OptionParser.new
    opts.on("-hSERVER", "--host=SERVER", "MySql server host", String) do |host|
      @host = host
    end
    opts.on("-uUSER", "--user=USER", "MySql user", String) do |user|
      @user = user
    end
    opts.on(
      "-pPASSWORD", "--password=PASSWORD", "MySql password", String
    ) do |password| 
      @password = password
    end
    opts.on(
      "-dDATABASE", "--database=DATABASE", "Database name", String
    ) do |database|
      @database = database
    end
    opts.on(
      "-fFORMAT", "--format=FORMAT", "Format: dot, png or any graphviz supported format", String
    ) do |format|
      @format = format
    end
    opts.on("-oFILE", "--output=FILE", "Output file", String) do |output_file|
      @output_file = output_file
    end
    opts.parse(ARGV)

    if @database == nil then
      $stderr.puts("You must choose the database")
      exit 1
    end

    @host = @host || "localhost"
    @user = @user || Etc.getlogin
    @format = @format || "png"
    @output_file = @output_file || @database + "_" + Time.new.to_s.gsub(" ", "_") + "." + @format
  end

end
