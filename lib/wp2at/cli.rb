require 'yaml'
class Wp2at::CLI

    def call
        user_config = YAML.load(File.read("user_config.yml"))
        puts "Welcome"
    end
end