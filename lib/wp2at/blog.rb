class Blog
    attr_accessor :name, :url, :base_name, :base_id, :table

    def initialize(name, url="", base_name="", base_id="", table="")
        puts "Add a website for #{name}:"
        url = STDIN.gets.chomp
        puts "Add a base for #{name}"
        base_name = STDIN.gets.chomp
        puts "Add a base_id"
        base_id = STDIN.gets.chomp
        puts "Add a table name"
        table = STDIN.gets.chomp
       @name = name
       @url = url
       @base_name = base_name
       @base_id = base_id
       @table = table
    end

    def missing_pieces(name)
       
    end
    

end