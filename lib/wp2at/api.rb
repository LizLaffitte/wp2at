require 'httparty'
require 'pry'
class API
    attr_accessor :routes, :at_latest, :total

    @@wp_api = "/wp-json/wp/v2/posts"
    @@at_api = "https://api.airtable.com/v0/"

    def initialize(settings, blog, flags="")
        @cs = settings
        @blog = blog
        @@wp_api.prepend(blog.url)
        @@at_api += @blog.base_id + "/" + replace_space(@blog.table) 
    end


    def collect_row_data(post_hash)
        offset = ""
        loop do
            at_response = call_at(code(["fields[]", @cs.headers[:id]], ["filterByFormula", "NOT({#{@cs.headers[:id]}} = '')"]),offset)
            if  at_response.parsed_response["records"]
                at_response.parsed_response["records"].collect do |post| 
                    post_hash[post["fields"][@cs.headers[:id]]]["at"] =  post["id"]
                end
                offset = at_response.parsed_response["offset"]
            elsif at_response.parsed_response["error"]
                puts  at_response.parsed_response["error"]["message"]
            end
            break if !at_response.parsed_response["offset"]
        end
        post_hash
    end

    def call_at(params ="", offset="")
        HTTParty.get(@@at_api + "?" + params + "&offset=" + offset, 
            :headers => {
                "Authorization" => "Bearer #{@cs.at_api}", 
                "Content-Type" => "application/json"
            })
    end

    def collect_post_data
        x = 1
        wp_posts = []
        until x > self.total
            resp = HTTParty.get(@@wp_api + "?_fields=id,title,date,link" + "&per_page=100&page=" + x.to_s)
            wp_posts.push(resp.parsed_response)
            total = resp.headers["x-wp-totalpages"].to_i
            x += 1
        end
        format_post_data(wp_posts)
    end

    def format_post_data(wp_data)
        post_data = {}
        wp_data.flatten.each{|post| post_data[post["id"]] = post }
        post_data
    end
    
    def code(*args)
        subs = {"%28" => "(", "%29" => ")", "%27" => "'"}
        return URI.encode_www_form(args).gsub(/(%28|%27|%29)/,subs)
    end

    def replace_space(string)
        return string.gsub(" ", "%20")
    end

    def prep_data(results, updates=false)
        records = []
        results.collect do |id, post|
            post[@cs.headers[:id]] = post.delete("id")
            post[@cs.headers[:title]] = post["title"].delete("rendered")
            post.delete("title")
            post[@cs.headers[:date]] = post.delete("date").split("T").first
            post[@cs.headers[:url]] = post.delete("link")
            if updates
                id = post["at"]
                post.delete("at")
                records.push({:id=> id,:fields => post})
            else
                records.push({:fields => post})
            end
            
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
            all_data = collect_row_data(post_data)
            results = compare_datasets(all_data)
            if results[:new].count > 0
                data = prep_data(results[:new])
                add_to_at(data, @@at_api)  
            else
                puts "No new posts."
            end
            if results[:current].count > 0
               data = prep_data(results[:current], true)
               update_at(data, @@at_api)
            end
        else
            puts "There was an issue. Try correcting your blog's URL"
        end
        
    end

    def compare_datasets(all_data)
        split_posts = all_data.partition{|k,v| v.has_key?("at")}.map(&:to_h)
        all_posts = {
            :new=> split_posts[1],
            :current=> split_posts[0]
        }
    end


    def add_to_at(data, at_route)
        data.each_slice(10) do |slice| 
            at_response = HTTParty.post(at_route, 
            :body => {:records => slice}.to_json,
            :headers => {"Authorization" => "Bearer #{@cs.at_api}", "Content-Type" => "application/json"}
             )
            if at_response["error"]
                case at_response["error"]["type"]
                when "UNKNOWN_FIELD_NAME"
                    puts "Incorrect table header(s). Try renaming #{at_response["error"]["message"].split("name: ")[1]}"
                    break
                else
                    if at_response["error"]["message"]
                        puts "AirTable Error:" +  at_response["error"]["message"]
                    else 
                        puts "AirTable Error:" +  at_response["error"]
                    end
                    break
                end
            end
        end
        puts "Blog data added!"
    end

    def update_at(data, at_route)
        data.each_slice(10) do |slice| 
            at_response = HTTParty.patch(at_route, 
            :body => {:records => slice}.to_json,
            :headers => {"Authorization" => "Bearer #{@cs.at_api}", "Content-Type" => "application/json"}
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
        puts "Blog data updated!"

    end
end