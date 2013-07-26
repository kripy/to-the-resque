worker_processes 4 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
preload_app true   # avoid regeneration of jekyll site for each fork

@resque_pid = nil
#@resque_pid2 = nil

before_fork do |server, worker|
  @resque_pid ||= spawn("bundle exec rake resque:work TERM_CHILD=1")
  #@resque_pid2 ||= spawn("bundle exec rake resque:work TERM_CHILD=1")
end