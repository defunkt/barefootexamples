class Barefoot
  def call(env)
    [ 200, 'Yes sir!', { 'Content-Type' => 'text/plain'} ]
  end
end

Rack::Handler::Mongrel.run(Barefoot.new, :Port => 8000) do |server|
  trap("INT") { server.stop }
end