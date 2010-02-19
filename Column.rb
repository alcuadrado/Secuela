# encoding: utf-8

class Column

  attr_accessor :name, :type

  def initialize(options)
    self.name = options[:name]
    self.type = options[:type]
  end

end
