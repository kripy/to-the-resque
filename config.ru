require './app'
require 'resque/server'

run Rack::URLMap.new \
  "/"       => App.new,
  "/resque" => Resque::Server.new