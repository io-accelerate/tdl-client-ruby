require 'rake/testtask'
require 'coveralls/rake/task'


#~~~~~~~ Test

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

Coveralls::RakeTask.new
task :test_with_coveralls => [:test, 'coveralls:push']


#~~~~~~~~~ Play

desc 'Run the example'
task :example do
  sh 'jruby -I lib examples/solve.rb'
end


desc 'Run the test playground'
task :playground do
  sh 'jruby -I lib ./test/utils/jmx/broker/playground.rb'
end


#~~~~~~~~ Deploy

require 'tdl/version'

task :build do
  system 'gem build tdl-client-ruby.gemspec'
end

task :release => :build do
  system "gem push tdl-client-ruby-#{TDL::VERSION}.gem"
end