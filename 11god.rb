rails_root = "/data/github/current"

God.watch do |w|
  w.name     = 'bj'
  w.interval = 30.seconds
  w.start    = "#{rails_root}/script/bj run --forever --rails_env=production --rails_root=#{rails_root}"

  w.uid = 'git'
  w.gid = 'git'

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end
  
  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end
    
    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end
  
  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
