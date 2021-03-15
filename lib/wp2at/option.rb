require 'yaml'
class Wp2at::Option
    

    def execute(args)
        command = args[0]
        options = args[1]
        case command
        when "userconfig"
           add_username(options)
        else
            puts "That's not an option"
        end
    
    end

    def add_username(username)
        @current_settings = Settings.new(username)
        puts @current_settings.username
    end

end