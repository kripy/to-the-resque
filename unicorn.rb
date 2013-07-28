worker_processes 4
timeout 30
preload_app true

@resque_pid = nil
@resque_pid2 = nil

before_fork do |server, worker|
  @resque_pid ||= spawn("env TERM_CHILD=1 bundle exec rake resque:work")
  @resque_pid2 ||= spawn("env TERM_CHILD=1 bundle exec rake resque:work")
end