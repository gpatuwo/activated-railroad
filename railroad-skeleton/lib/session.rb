require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    # TODO change name of cookie after finish specs
    @cookie_name = "_rails_lite_app"
    cookie = req.cookies[@cookie_name]

    # if cookie has been set, then deserialize value of cookie
    cookie ? @data = JSON.parse(cookie) : @data = {}
  end

  # fetches/mods the session content so Session is Hash-like
  def [](key)
    @data[key]
  end

  def []=(key, val)
    @data[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    attributes = {}
    attributes[:path] = "/"
    attributes[:value] = @data.to_json
    res.set_cookie(@cookie_name, attributes)
  end
end
