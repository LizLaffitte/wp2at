require 'yaml'
class CLI
    options = {}

    def call
      Settings.load ? menu : new_user

    end


    def menu
        option = ""
        puts "Welcome, #{@current_settings.username}!"
        puts "Choose an option:"
        
        
    end
    
    

    def update
        print_blogs
    end

    def print_blogs
        @current_settings.blogs.sort_by(&:name).each.with_index(1){|blog, idx| puts "#{idx}. #{blog.name}" }
    end

    def new_user
        puts "Welcome, new user!"
        add_username
        puts "Now we need an AirTable API key."
        add_atapi
        puts "Let's add a blog"
        add_blogs
        puts "Great! You now have #{@current_settings.blog_count} blogs."
        menu
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
            
            puts "Enter the name of the base we'll be adding this blog info to."
            base_name = gets.chomp
            puts "Enter the id of the base."
            base_id = gets.chomp
            puts "Enter the table name."
            table_name = gets.chomp
            blog = Blog.new(blog_name,blog_url,base_name, base_id, table_name)
            @current_settings.add_blog(blog)
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