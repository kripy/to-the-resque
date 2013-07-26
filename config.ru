require './app'
require 'resque/server'

use Rack::Deflater

run Rack::URLMap.new \
  "/"       => App.new,
  "/resque" => Resque::Server.new