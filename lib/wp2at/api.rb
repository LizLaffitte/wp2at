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
        row_data = {}
        offset = ""
        loop do
            at_response = call_at("",offset)
            at_response.parsed_response["records"].collect{|post| row_data[post["fields"]["ID"]] = post["id"]}
            offset = at_response.parsed_response["offset"]
            break if !at_response.parsed_response["offset"]
        end
        row_data
    end

    def call_at(params ="", offset="")
        HTTParty.get(@@at_api + "?" + params + "&offset=" + offset, 
            :headers => {
                "Authorization" => "Bearer #{@current_settings.at_api}", 
                "Content-Type" => "application/json"
            })
    end

    def collect_post_data
        ping_wp
        x = 1
        wp_posts = []
        until x > self.total
            resp = HTTParty.get(@@wp_api + "?_fields=id,title,date,link" + "&per_page=100&page=" + x.to_s)
            wp_posts.push(resp.parsed_response)
            total = resp.headers["x-wp-totalpages"].to_i
            x += 1
        end
        post_data = {
            :posts => wp_posts.flatten,
            :ids => wp_posts.flatten.collect{|post| post["id"]}
        }       
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
        post_data = collect_post_data()
        rows = collect_row_data
        new_posts = compare_datasets(rows.keys, post_data[:ids])
        if new_posts
            data = prep_data(post_data[:posts].keep_if{|post| new_posts.include? post["id"]})
            add_to_at(data, @@at_api)  
        else
            data = prep_data(post_data[:posts].keep_if{|post| post_data[:ids].include? post["id"]})
            # binding.pry
            puts "All data up-to-date"
        end
        
    end

    def compare_datasets(at_arr, wp_arr)
        new_posts = wp_arr - at_arr
        if new_posts.count > 0 
            new_posts
        else
            false
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

    def update_at(data)
    end
end