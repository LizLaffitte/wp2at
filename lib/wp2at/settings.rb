require 'yaml'
class Settings
    attr_accessor :username, :base
    attr_reader :blogs, :at_api

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

    def at_api=(key)
        @at_api = key
        self.settings_save
        self.at_api
    end

    def username=(username)
        @username = username
        self.settings_save
        self.username
    end

    def blog_count
        self.blogs.count
    end

    def list_blogs
        if self.blog_count > 0  
            self.blogs.each.with_index(1){|blog, idx| puts "#{idx}. #{blog.name} \n URL: #{blog.url} \n Base Name & ID: #{blog.base_name}, #{blog.base_id} \n Table Name: #{blog.table}" }
        else
            puts "No blogs added."
        end
    end

    
end