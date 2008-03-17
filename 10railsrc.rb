require 'logger'
Object.const_set(:RAILS_DEFAULT_LOGGER, Logger.new(STDOUT))

load 'Rakefile'
def rake(task)
  Rake::Task[task.to_s].invoke 
end

def routes
  rake 'routes'
end

def Object.method_added(method)
  ($rails_hacks ||= []) << method
  super
end

def loud_logger
  set_logger_to Logger.new(STDOUT)
end

def quiet_logger
  set_logger_to nil
end

def set_logger_to(logger)
  ActiveRecord::Base.connection.instance_variable_set(:@logger, logger)
end

def sql(query)
  ActiveRecord::Base.connection.select_all(query)
end 

def body
  app.response.body.squeeze(' ').squeeze("\n")
end

def rails_hacks
  $rails_hacks
end

def Object.method_added(method)
  return super unless method == :helper
  (class<<self;self;end).send(:remove_method, :method_added)

  def helper(*helper_names)
    returning $helper_proxy ||= Object.new do |helper|
      helper_names.each { |h| helper.extend "#{h}_helper".classify.constantize }
    end
  end

  helper.instance_variable_set("@controller", ActionController::Integration::Session.new)

  def helper.method_missing(method, *args, &block)
    @controller.send(method, *args, &block) if @controller && method.to_s =~ /_path$|_url$/
  end

  helper :application rescue nil
end 

def method_missing(method, *args, &block)
  User.find_by_login(method.to_s) || super
end
