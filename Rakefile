require 'bundler/setup'

gemspec = eval(File.read("venice.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["venice.gemspec"] do
  system "gem build venice.gemspec"
end
