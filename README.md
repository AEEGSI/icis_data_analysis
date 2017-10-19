# ICIS data analysis

Collection of classes, modules and methods used to do basic calculation and analysis on Natural Gas data provided by ICIS.


## Usage

### PSV prices

The file ``use/read_and_analyse_psv_prices.rb`` provide two methods: ``read_psv`` read an Excel file with data about PSV prices and set attributes, ``write_output`` generate an Excel file.

```ruby
ruby use/read_and_analyse_psv_prices.rb
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AEEGSI/icis_data_analysis. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

