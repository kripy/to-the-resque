require 'bundler/setup'
Bundler.require(:default)

require File.expand_path('../lib/watermark', __FILE__)
require File.expand_path('../lib/redis_keys', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/support'
require 'compass'
require 'compass-h5bp'
require 'mustache/sinatra'
require 'sinatra/redis'

class App < Sinatra::Base
  base = File.dirname(__FILE__)
  set :root, base

  configure do
    uri = URI.parse(ENV["REDISTOGO_URL"])
    puts uri
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    Resque.redis.namespace = "resque:example"
    set :redis, ENV["REDISTOGO_URL"]
  end

  register Sinatra::AssetPack
  register Sinatra::CompassSupport
  register Mustache::Sinatra

  set :sass, Compass.sass_engine_options
  set :sass, { :load_paths => sass[:load_paths] + [ "#{base}/app/css" ] }

  assets do
    serve '/js',    from: 'app/js'
    serve '/css',   from: 'app/css'
    serve '/img',   from: 'app/img'

    css :app_css, [ '/css/*.css' ]
    js :app_js, [
      '/js/*.js',
      '/js/vendor/jquery-1.9.1.min.js',
    ]
    js :app_js_modernizr, [ '/js/vendor/modernizr-2.6.2.min.js' ]
  end

  require "#{base}/app/helpers"
  require "#{base}/app/views/layout"

  set :mustache, {
    :templates => "#{base}/app/templates",
    :views => "#{base}/app/views",
    :namespace => App
  }

  before do
    @css = css :app_css
    @js  = js  :app_js
    @js_modernizr = js :app_js_modernizr
  end

  helpers do

  end

  # Function allows both get / post.
  def self.get_or_post(path, opts={}, &block)
    get(path, opts, &block)
    post(path, opts, &block)
  end   

  get "/" do
    @local_uploads = redis.get(local_uploads_key)
    @s3_originals = redis.get(s3_originals_key)
    @s3_watermarked = redis.get(s3_watermarked_key)
    @watermarked_urls = redis.lrange(watermarked_url_list, 0, 4)
    @working = Resque.working

    mustache :index
  end

  post '/upload' do
    unless params['file'][:tempfile].nil?
      tmpfile = params['file'][:tempfile]
      name = params['file'][:filename]
      redis.incr(local_uploads_key)
      file_token = send_to_s3(tmpfile, name)
      Resque.enqueue(Watermark, file_token.key)
    end
  end

  def send_to_s3(tmpfile, name)
    connection = Fog::Storage.new({
      :provider => 'AWS',
      :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    })

    directory = connection.directories.get(ENV['AWS_S3_BUCKET_ORIGINALS'])

    file_token = directory.files.create(
      :key    => name,
      :body   => File.open(tmpfile),
      :public => true
    )
    
    redis.incr(s3_originals_key)
    file_token
  end
end