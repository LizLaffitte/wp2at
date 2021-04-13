require 'yaml'
class Wp2at::Option
    

    def execute(args)
        command = args[0]
        options = args[1]
        flags = args[2]
        @current_settings = Settings.exists? ? Settings.load : Settings.new
        case command
        when "userconfig"
            puts options ? @current_settings.username = options : @current_settings.username
        when "blog" 
            options ? @current_settings.add_blog(options) : @current_settings.list_blogs 
        when "api-key"
            puts options ? @current_settings.at_api = options : @current_settings.at_api
        when "sync"
            if options
                if @current_settings.blog_count < 1
                    puts "Add a blog by running blog with an argument of the blog name you'd like to add."
                end
                if @current_settings.at_api != ""
                    blog = @current_settings.blogs.find{|blog| blog.name == options}
                    if blog
                        api = API.new(@current_settings, blog)
                        api.sync(flags)
                    else 
                        puts "Blog not added. Add it by running: `$blog #{options}`"
                    end
                else
                    puts "Add an AirTable API Key by running the command api-key and passing an API key."
                end
            else
                puts "No blogs added. Try running 'blog' to sync a blog."
            end
        when "headers"
            puts @current_settings.headers
        else
            puts "That's not an option"
        end
    
    end

end