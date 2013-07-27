require File.expand_path('../redis_keys', __FILE__)
require 'resque/errors'

module RetriedJob
  def on_failure_retry(e, *args)
    puts "Performing #{self} caused an exception (#{e}). Retrying..."
    $stdout.flush
    Resque.enqueue self, *args
  end
end

class Watermark
  extend RetriedJob

  attr_reader :originals_directory, :watermarked_directory, :connection, :original_file
  @queue = :watermark

  def initialize(key)
    @connection = get_connection
    @originals_directory = connection.directories.get(ENV['AWS_S3_BUCKET_ORIGINALS'])
    @watermarked_directory = connection.directories.get(ENV['AWS_S3_BUCKET_WATERMARKED'])

    @original_file = @originals_directory.files.get(key)
    flush "Initialized Watermark worker instance"
  end

  def get_connection
    conn = Fog::Storage.new({
      :provider => 'AWS',
      :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    })
  end

  def self.perform(key)
    (new key).apply_watermark
    rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  def apply_watermark
    Dir.mktmpdir do |tmpdir|
      tmpfile = File.join(tmpdir, @original_file.key)

      flush "Opening original file locally: #{tmpfile}"
      File.open(tmpfile, 'w') { |f| f.write(@original_file.body) }
      image = MiniMagick::Image.open(tmpfile)

      result = image.composite(MiniMagick::Image.open("watermark.png", "jpg")) do |c|
        c.dissolve "15"
        c.gravity "center"
      end

      watermarked_local_file = "#{tmpdir}/watermarked_#{@original_file.key}"
      result.write(watermarked_local_file)
      flush "Writing watermarked file locally: #{watermarked_local_file}"

      save_watermarked_file(watermarked_local_file)
      redis.incr(s3_watermarked_key)
    end 
  end

  def save_watermarked_file(watermarked_local_file)
      watermarked_file_token = @watermarked_directory.files.create(
      :key    => @original_file.key,
      :body   => File.open(watermarked_local_file),
      :public => true
    )
    redis.lpush(watermarked_url_list, watermarked_file_token.public_url)
    flush "Persisted watermarked file to S3: #{watermarked_file_token.public_url}"
  end

  def flush(str)
    puts str
    $stdout.flush
  end
end
