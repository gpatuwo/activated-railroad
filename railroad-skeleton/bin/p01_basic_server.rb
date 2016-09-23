require 'rack'

# Rack is a middleware that sits between a web server and a web app framework to make it easier to write frameworks + servers that work with existing software.

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  #  Content-Type tells the browser what the server has given it in response
  res['Content-Type'] = 'text/html'
  res.write("Hello world!")
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
