require 'yaml'
class Wp2at::Option
    

    def execute(args)
        command = args[0]
        options = args[1]
        @current_settings = Settings.exists? ? Settings.load : Settings.new
        case command
        when "userconfig"
            puts options ? add_username(options) : @current_settings.username
        when "blog" 
            options ? @current_settings.add_blog(options) : @current_settings.list_blogs 
        else
            puts "That's not an option"
        end
    
    end


    def add_username(username="")
        @current_settings.username = username
        @current_settings.settings_save
        @current_settings.username
    end

end