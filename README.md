[![jRuby Version](http://img.shields.io/badge/Ruby-2.2.2-blue.svg)](http://jruby.org/2015/07/09/jruby-9-0-0-0-rc2.html)
[![Gem Version](http://img.shields.io/gem/v/tdl-client-ruby.svg)](https://rubygems.org/search?query=tdl-client-ruby)
[![Codeship Status for julianghionoiu/tdl-client-ruby](https://img.shields.io/codeship/1072db10-0fc1-0133-f3de-1e6fe7bb1028.svg)](https://codeship.com/projects/91966)
[![Coverage Status](https://coveralls.io/repos/julianghionoiu/tdl-client-ruby/badge.svg?branch=master&service=github)](https://coveralls.io/github/julianghionoiu/tdl-client-ruby?branch=master)

# tdl-client-ruby

### Submodules

Project contains submodules as mentioned in the `.gitmodules` file:

- broker
- tdl/client-spec (gets cloned into features/spec)
- wiremock 

Use the below command to update the submodules of the project:

```
git submodule update --init
```

### Getting started

Ruby client to connect to the central kata server.

### Installing 

#### Install RBENV

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# Then activate
~/.rbenv/bin/rbenv init
```

#### Install ruby
```bash
rbenv install 3.4.2
rbenv local 3.4.2
ruby --version
```

If the above fails, you might need to install libyaml:
```shell
https://pyyaml.org/download/libyaml/

./configure
make
make install
```

#### Install bundler
```bash
gem install bundler
```

#### Install cucumber
```bash
gem install cucumber
```

#### Install all the gems in the project
```bash
bundle install
```


# Testing

All test require the ActiveMQ broker and Wiremock to be started.

Start ActiveMQ
```shell
export ACTIVEMQ_CONTAINER=apache/activemq-classic:6.1.0
docker run -d -it --rm -p 28161:8161 -p 21613:61613 -p 21616:61616 --name activemq ${ACTIVEMQ_CONTAINER}
```

The ActiveMQ web UI can be accessed at:
http://localhost:28161/admin/
use admin/admin to login

Start two Wiremock servers
```shell
export WIREMOCK_CONTAINER=wiremock/wiremock:3.7.0
docker run -d -it --rm -p 8222:8080 --name challenge-server ${WIREMOCK_CONTAINER}
docker run -d -it --rm -p 41375:8080 --name recording-server ${WIREMOCK_CONTAINER}
```

The Wiremock admin UI can be found at:
http://localhost:8222/__admin/
and docs at
http://localhost:8222/__admin/docs


# Cleanup

Stop dependencies
```
docker stop activemq
docker stop recording-server
docker stop challenge-server
```

# Tests

Run tests with:
```
bundle exec rake features
```
To run a single scenario execute `cucumber path/to/file.feature:line_no`
Recommendation is to use the cucumber command instead of rake always outside of CI.

## To release

Check the version in:
```
lib/tdl/previous_version.rb
```

Build Gem
```
bundle exec rake build
```

Push to Rubygems
```
bundle exec rake release
```

Manually update the version in:
```
lib/tdl/previous_version.rb
```