require 'rake'
require 'rake/testtask'

task :default => :test
task :test => "test:all"

namespace :test do
  Rake::TestTask.new(:all) do |test|
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end

  Rake::TestTask.new(:units) do |test|
    test.pattern = 'test/unit/**/*_test.rb'
    test.verbose = true
  end
end

