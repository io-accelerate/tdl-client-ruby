require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc 'Run the example'
task :example do
  sh 'jruby -I lib examples/solve.rb'
end


desc 'Run the test playground'
task :playground do
  sh 'jruby -I lib ./test/utils/jmx/broker/playground.rb'
end