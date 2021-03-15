require 'yaml'
class Settings
    attr_accessor :username, :at_api
    attr_reader :blogs

    def initialize(username, blogs=[], at_api = "", bases=[])
        @username = username
        @blogs = blogs
        @at_api = at_api
        @blog_count = @blogs.count
    end

    def self.load
        if(File.size?("user_config.yml"))
            true
        else
            false
        end
    end

    def add_blog(blog)
        self.blogs << blog
    end

    def blog_count
        self.blogs.count
    end


    
end