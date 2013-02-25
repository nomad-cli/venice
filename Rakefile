require 'bundler/setup'
require 'appraisal'

gemspec = eval(File.read("venice.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["venice.gemspec"] do
  system "gem build venice.gemspec"
  system "gem install venice-#{Venice::VERSION}.gem"
end
