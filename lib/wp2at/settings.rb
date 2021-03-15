require 'yaml'
class Settings
    attr_accessor :username, :at_api, :base
    attr_reader :blogs

    def initialize(username="", blogs=[], at_api = "", base={})
        @username = username
        @blogs = blogs
        @at_api = at_api
        @blog_count = @blogs.count
        @base = base  
    end

    def self.exists?
        if(File.size?("wp2at_config.yml"))
            true
        else
            false
        end
    end

    def self.load
        Settings.new(YAML.load(File.read("wp2at_config.yml")))
    end

    def settings_save
        settings = {
	        username: self.username, at_api: self.at_api, blogs: self.blogs, base: self.base
        }
        File.open("wp2at_config.yml", "w"){|file| file.write(settings.to_yaml)}
    end

    def add_blog(blog)
        self.blogs << blog
    end

    def blog_count
        self.blogs.count
    end

    def read_blogs
        self.blogs.each.with_index(0){|blog, idx| puts "#{idx}. #{blog.name}" }
    end

    
end