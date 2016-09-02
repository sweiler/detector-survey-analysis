Bundler.require(:default, :test)

task :default => [:spec]

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '-f d'
  end
rescue LoadError
end
