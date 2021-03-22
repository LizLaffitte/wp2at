class API
    attr_accessor :routes

    def initialize(current_settings)
        @routes = current_settings.blogs.collect{|blog| blog.url}
    end

    def list_blogs
        puts self.routes
    end
end