require 'yaml'
class Settings
    attr_accessor :username, :at_api, :base
    attr_reader :blogs

    def initialize(settingsHash={:username=>"", :at_api=>"", :blogs=>[], :base=>{}})
        @username = settingsHash[:username]
        @blogs = settingsHash[:blogs]
        @at_api = settingsHash[:at_api]
        @blog_count = @blogs.count
        @base = settingsHash[:base]
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

    def add_blog(options)
        blog = Blog.new(options)
        self.blogs << blog
        self.settings_save
    end

    def blog_count
        self.blogs.count
    end

    def list_blogs
        if self.blog_count > 0  
            self.blogs.each.with_index(1){|blog, idx| puts "#{idx}. #{blog.name}" }
        else
            puts "No blogs added."
        end
    end

    
end