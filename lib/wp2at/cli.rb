require 'yaml'
class CLI

    def call
      Settings.load ? welcome : new_user
    end

    def welcome
        puts "Hello!"
    end

    def new_user
        puts "Welcome, new user!"
        add_username
        puts "Let's add a blog post"
        add_blogs
        puts "Great! You now have #{@current_settings.blog_count} blogs."
        puts "Now we need an AirTable API key."
        add_atapi
    end

    def edit_username
        puts "Your username is: #{@current_settings.username}. Would you like to change it? (y/n)"
        edit = gets.chomp
        until !edit
            puts "What should we call you?"
            @current_settings.username = gets.chomp
            puts "Your username is: #{@current_settings.username}. Would you like to change it? (y/n)"
            edit = gets.chomp
        end
    end

    def add_username
        puts "What should we call you?"
        user = gets.chomp
        @current_settings = Settings.new(user)
        puts "Nice to meet you #{@current_settings.username}"
    end

    def add_blogs
       add = 'y'
        while add == 'y'
            puts "Please add the name of your WordPress blog:"
            blog_name = gets.chomp  
            puts "Please add a URL for #{blog_name}."
            blog_url = gets.chomp   
            puts "#{blog_name}: #{blog_url}"
            @current_settings.blogs << {blog_name: blog_url}
            puts "Would you like to add a blog? (y/n)"
            add = gets.chomp.downcase
        end
    end

    def add_atapi
        puts "Enter your API key"
        at_api = gets.chomp
        puts at_api
        @current_settings.at_api = at_api
    end


end