require 'yaml'
class Settings
    attr_accessor :username, :at_api, :blogs, :bases

    def initialize(username, blogs=[], at_api = "", bases=[])
        @username = username
        @blogs = blogs
        @at_api = at_api
        @blog_count = @blogs.count
        @bases = bases
    end

    def self.load
        if(File.size?("user_config.yml"))
            true
        else
            false
        end
    end

    def add_blog(name, blog_url)
        self.blogs << {name: blog_url}
    end

    def blog_count
        self.blogs.count
    end

    def add_bases(name, id)
        self.bases << {name: id}
    end
    
end