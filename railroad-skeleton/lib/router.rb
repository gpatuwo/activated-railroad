class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method = pattern, http_method
    @controller_class, @action_name = controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    !!(@pattern =~ req.path) &&
      (req.request_method.downcase.to_sym == @http_method)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    @controller_class
      .new(req, res, {})
      .invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes.push(Route.new(pattern, method, controller_class, action_name))
  end

  # evaluate the proc in the context of the instance for syntactic sugar :)
  def draw(&proc)
    instance_eval(&proc)
  end


  # makes method. when called, adds route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # find, return first matching route
  def match(req)
    @routes.find {|route| route.matches?(req)}
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
