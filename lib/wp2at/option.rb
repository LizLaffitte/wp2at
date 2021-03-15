require 'yaml'
class Wp2at::Option
    

    def execute(args)
        command = args[0]
        options = args[1]
        @current_settings = Settings.exists? ? Settings.load : Settings.new
        case command
        when "userconfig"
            options ? add_username(options) : @current_settings.username
        when "blog"
            options ? add_blog(options) : @current_settings.list_blogs 
        else
            puts "That's not an option"
        end
    
    end

    def add_username(username)
        @current_settings.username = username
        @current_settings.settings_save
        puts @current_settings.username
    end

end