class Theme
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def fields
    YAML.load_file("themes/#{@name}.yml")["fields"]
  end
end
