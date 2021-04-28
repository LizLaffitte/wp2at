# WP2AT
A Ruby gem built to help WordPress bloggers keep track of their posts in AirTable.

You enter your WordPress website URL and AirTable data (base name, base ID, table name, API key), and the gem syncs your WordPress blog data (ID, post title, date published, URL) in the specified table.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wp2at'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install wp2at

## Usage
Unless you've added the gem to your path, all commands are prefaced with ./bin/wp2at and must be run from within the gem's directory. 

### Commands
To add a username:          --userconfig 

To add a WordPress blog:    --blog BLOG NAME

To add an AirTable API key: --apikey YOUR-API-KEY

To syn your blog post data: --sync BLOG NAME

To change AirTable column names: --headers COLUMN-TO-CHANGE

Your settings are saved in a local file(wp2at_config.yml).


 The gem will look for the following table column names and field types:

* ID  -- number (integer)
* Title -- text
* Date -- date
* URL -- url

To change AirTable column names, run  --headers COLUMN-TO-CHANGE
e.g.
```
./bin/wp2at headers id
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lizlaffitte/wp2at. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lizlaffitte/wp2at/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wp2at project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lizlaffitte/wp2at/blob/master/CODE_OF_CONDUCT.md).
