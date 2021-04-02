require 'httparty'
class API
    attr_accessor :routes, :at_latest, :wp_latest, :total


    @@wp_api = "/wp-json/wp/v2/posts?_fields=id,title,date,link"
    @@at_api = "https://api.airtable.com/v0/"

    def initialize(settings, blog, flags="")
        @current_settings = settings
        @blog = blog
        @@wp_api.prepend(blog.url)
        @@at_api += @blog.base_id + "/" + replace_space(@blog.table) 
    end


    def latest_record
        at_response = HTTParty.get(@@at_api + "?sort%5B0%5D%5Bfield%5D=ID&sort%5B0%5D%5Bdirection%5D=desc", 
            :headers => {"Authorization" => "Bearer #{@current_settings.at_api}", "Content-Type" => "application/json"})
        # id_array = at_response.parsed_response["records"].collect{|post| post["fields"]["ID"]}
        # id_array
        if at_response.parsed_response["records"].length > 0
            @at_latest = at_response.parsed_response["records"].first["fields"]["ID"]
        else 
            @at_latest = "0"
        end
    end

    def collect_post_data
        x = 1
        resp_array = []
        until x > self.total
            resp = HTTParty.get(@@wp_api + "&per_page=100&page=" + x.to_s)
            resp_array.push(resp.parsed_response)
            total = resp.headers["x-wp-totalpages"].to_i
            puts x
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

    def ping
        resp = HTTParty.get(@@wp_api + "&per_page=100")
        @wp_latest = resp.parsed_response[0]["id"]
        @total = resp.headers["x-wp-totalpages"].to_i
        latest_record
    end
    def sync(flags)
        ping
        
        if flags
            if @wp_latest == @at_latest
                puts "up to date"
            end
        else
            posts = collect_post_data()
            data =  prep_data(posts)
            add_to_at(data, @@at_api)   
        end    
    end

    def add_to_at(data, at_route)
        data.each_slice(10) do |slice| 
            at_response = HTTParty.post(at_route, 
            :body => {:records => slice}.to_json,
            :headers => {"Authorization" => "Bearer #{@current_settings.at_api}", "Content-Type" => "application/json"}
             )
            at_response
        end
    end

end