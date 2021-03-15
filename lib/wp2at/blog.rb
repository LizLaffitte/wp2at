class Blog
    attr_accessor :name, :url, :base_name, :base_id, :table

    def initialize(name, url, base_name, base_id, table)
       @name = name
       @url = url
       @base_name = base_name
       @base_id = base_id,
       @table = table
    end


    

end