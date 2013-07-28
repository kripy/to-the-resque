worker_processes 4
timeout 30
preload_app true

@resque_pid = nil
@resque_pid2 = nil

before_fork do |server, worker|
  @resque_pid ||= spawn("bundle exec rake resque:work TERM_CHILD=1")
  @resque_pid2 ||= spawn("bundle exec rake resque:work TERM_CHILD=1")
end