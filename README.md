[![jRuby Version](http://img.shields.io/badge/Ruby-2.2.2-blue.svg)](http://jruby.org/2015/07/09/jruby-9-0-0-0-rc2.html)
[![Gem Version](http://img.shields.io/gem/v/tdl-client-ruby.svg)](https://rubygems.org/search?query=tdl-client-ruby)
[![Codeship Status for julianghionoiu/tdl-client-ruby](https://img.shields.io/codeship/1072db10-0fc1-0133-f3de-1e6fe7bb1028.svg)](https://codeship.com/projects/91966)
[![Coverage Status](https://coveralls.io/repos/julianghionoiu/tdl-client-ruby/badge.svg?branch=master&service=github)](https://coveralls.io/github/julianghionoiu/tdl-client-ruby?branch=master)

# tdl-client-ruby

```
# Install RVM
curl -sSL https://get.rvm.io | bash -s stable
echo 'source /Users/julianghionoiu/.rvm/scripts/rvm' >> .bash_profile

# Install ruby
rvm install ruby-2.2.2
rvm use ruby-2.2.2

# Install bundler
gem install bundler
```

# Installing

# Testing

All test require the ActiveMQ broker to be started.
The following commands are available for the broker.

```
python ./broker/activemq-wrapper.py start
python wiremock/wiremock-wrapper.py start 41375
python wiremock/wiremock-wrapper.py start 8222
```

Run tests with `rake features`.
To run a single scenario execute `cucumber path/to/file.feature:line_no`
Recommendation is to use the cucumber command instead of rake always outside of CI.

# Cleanup

Stop external dependencies
```
python ./broker/activemq-wrapper.py stop
```


# To release

Run
```
./release.sh
```