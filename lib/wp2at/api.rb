require 'httparty'
class API
    attr_accessor :routes

    @@wp_api = "/wp-json/wp/v2/posts?_fields=id,title,date,link&per_page=100&page="
    @@at_api = "https://api.airtable.com/v0/"

    def initialize(current_settings)
        @current_settings = current_settings
        @routes = Hash.new
    end

    def list_blogs
        @current_settings.blogs.each{|blog| puts "#{blog.name}: #{blog.url}"}
    end

    def collect_post_data(url)
        x = 1
        total = 50
        resp_array = []
        
        until x > total
            resp = HTTParty.get(url + @@wp_api + x.to_s)
            resp_array.push(resp.parsed_response)
            total = resp.headers["x-wp-totalpages"].to_i
            x += 1
        end
        resp_array.flatten
    end
    
    def replace_space(string)
        return string.gsub(" ","%20")
    end

    def prep_data(results)
        records = []
        results.collect do |post|
            post["ID"] = post.delete("id")
            post["Title"] = post["title"].delete("rendered")
            post.delete("title")
            post["Date Published"] = post.delete("date")
            post["URL"] = post.delete("link")
            records.push({:fields => post})
        end
        records
    end

    def ping(blogname)
        blog = @current_settings.blogs.find{|blog| blog.name == blogname}
        results = collect_post_data(blog.url)
        at_route = @@at_api + blog.base_id + "/" + replace_space(blog.table) 
        data =  prep_data(results)
        add_to_at(data, at_route)
    end

    def add_to_at(data, at_route)
        data.each_slice(10) do |slice| 
            at_response = HTTParty.post(at_route, 
            :body => {:records => slice}.to_json,
            :headers => {"Authorization" => "Bearer #{@current_settings.at_api}", "Content-Type" => "application/json"}
             )
            puts at_response
        end
    end

end