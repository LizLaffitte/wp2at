require 'httparty'
require 'pry'
class API
    attr_accessor :routes, :at_latest, :total

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
            at_response = call_at("fields%5B%5D=ID&fields%5B%5D=Last+Modified",offset)
            at_response.parsed_response["records"].collect{|post| row_data[post["fields"][@current_settings.headers[:id]]] = [post["id"], post["fields"]["Last Modified"]]}
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
        x = 1
        wp_posts = []
        until x > self.total
            resp = HTTParty.get(@@wp_api + "?_fields=id,title,date,link,modified" + "&per_page=100&page=" + x.to_s)
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
            post[@current_settings.headers[:id]] = post.delete("id")
            post[@current_settings.headers[:title]] = post["title"].delete("rendered")
            post.delete("title")
            post[@current_settings.headers[:date]] = post.delete("date")
            post[@current_settings.headers[:url]] = post.delete("link")
            post.delete("modified")
            records.push({:fields => post})
        end
        records

    end

    def ping_wp
        begin
            resp = HTTParty.get(@@wp_api + "?_fields=id" + "&per_page=100")
        rescue
            false
        else
            @total = resp.headers["x-wp-totalpages"].to_i
            true
        end
    end
    def sync(flags)
        if ping_wp
            post_data = collect_post_data()
            at_data = collect_row_data
            all_data = compare_datasets(at_data, post_data)
            if all_data[:new].count > 0
                data = prep_data(post_data[:posts].keep_if{|post| all_data[:new].include? post["id"]})
                add_to_at(data, @@at_api)  
            else
      
                puts "All data up-to-date"
            end
        else
            puts "There was an issue. Try correcting your blog's URL"
        end
        
    end

    def compare_datasets(at_data, wp_data)
        # to_update = find_updates(wp_data, at_data)
        all_posts = {
            :new=> at_data.keys - wp_data[:ids],
            # :update=> to_update
        }
    end

    def find_updates(wp_data, at_data)
        
        binding.pry
    end

    def add_to_at(data, at_route)
        data.each_slice(10) do |slice| 
            at_response = HTTParty.post(at_route, 
            :body => {:records => slice}.to_json,
            :headers => {"Authorization" => "Bearer #{@current_settings.at_api}", "Content-Type" => "application/json"}
             )
            if at_response["error"]
                case at_response["error"]["type"]
                when "UNKNOWN_FIELD_NAME"
                    puts "Incorrect table header(s). Try renaming #{at_response["error"]["message"].split("name: ")[1]}"
                    break
                else
                    puts "AirTable Error:" +  at_response["error"]
                    break
                end
            end
        end
        puts "Blog data added!"
    end

    def update_at(data)

    end
end