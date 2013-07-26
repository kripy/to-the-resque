require 'bundler/setup'
Bundler.require(:default)

require './app'
require 'resque/tasks'

task "resque:setup" do
	ENV['QUEUE'] = '*'
end