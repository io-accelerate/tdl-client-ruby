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
brew install rbenv

# Then add this to bash_locations
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
```

#### Install ruby
```bash
rbenv install 3.2.2
rbenv local 3.2.2
ruby --version
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

#### Manual 

Stopping the wiremocks and broker services would be the same, using the `stop` command instead of the `start` command.

#### Automatic (via script)

Start and stop the wiremocks and broker services with the below:
 
```bash
./startExternalDependencies.sh
``` 

```bash
./stopExternalDependencies.sh
``` 

### Testing

All test require the ActiveMQ broker to be started.
The following commands are available for the broker.

```
java8
python3 ./broker/activemq-wrapper.py start
python3 wiremock/wiremock-wrapper.py start 41375
python3 wiremock/wiremock-wrapper.py start 8222
```

or 

```bash
./startExternalDependencies.sh
``` 

Run tests with:
```
bundle exec rake features
```
To run a single scenario execute `cucumber path/to/file.feature:line_no`
Recommendation is to use the cucumber command instead of rake always outside of CI.

### Cleanup

Stop external dependencies
```
java8
python3 ./broker/activemq-wrapper.py stop
python3 wiremock/wiremock-wrapper.py stop 41375
python3 wiremock/wiremock-wrapper.py stop 8222
```

or 

```bash
./stopExternalDependencies.sh
```


## To release

Run
```
./release.sh
```
