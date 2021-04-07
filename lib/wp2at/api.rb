require 'httparty'
require 'pry'
class API
    attr_accessor :routes, :at_latest, :wp_latest, :total


    @@wp_api = "/wp-json/wp/v2/posts"
    @@at_api = "https://api.airtable.com/v0/"

    def initialize(settings, blog, flags="")
        @current_settings = settings
        @blog = blog
        @@wp_api.prepend(blog.url)
        @@at_api += @blog.base_id + "/" + replace_space(@blog.table) 
    end


    def collect_row_data
        at_response = call_at
        
        row_data = at_response.parsed_response["records"].collect{|post| {post["id"] => post["fields"]["ID"]}}
    end

    def call_at(params ="", offset="")
        HTTParty.get(@@at_api + params + offsest, 
            :headers => {
                "Authorization" => "Bearer #{@current_settings.at_api}", 
                "Content-Type" => "application/json"
            })
    end

    def collect_post_data
        ping_wp
        x = 1
        resp_array = []
        until x > self.total
            resp = HTTParty.get(@@wp_api + "?_fields=id,title,date,link" + "&per_page=100&page=" + x.to_s)
            resp_array.push(resp.parsed_response)
            total = resp.headers["x-wp-totalpages"].to_i
            x += 1
            puts x
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

    def ping_wp
        resp = HTTParty.get(@@wp_api + "?_fields=id" + "&per_page=100")
        @wp_latest = resp.parsed_response[0]["id"]
        @total = resp.headers["x-wp-totalpages"].to_i
    end
    def sync(flags)
        posts = collect_post_data()
        rows = collect_row_data

        data =  prep_data(posts)
        
        # add_to_at(data, @@at_api)  
    end

    def find_updates

    end

    def find_new_rows
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