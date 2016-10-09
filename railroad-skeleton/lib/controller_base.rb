require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller. Takes in HTTP Request + Response objects
  def initialize(req, res, params)
    @req = req
    @res = res
    @params = params
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "you can't render twice :( " if already_built_response?
    # location is an Response instance method
    @res['Location'] = url
    # whereas status isan instance attribute
    @res.status = 302
    # so session data store in cookie after res built
    session.store_session(@res)

    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "you can't render twice :( " if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    # assuming template naming convention follows this:
    template_content = File.read("../views/#{controller_name}/#{template_name}.html.erb")

    # Kernel's binding bundles the environmental bindings and makes them available in another context (so in this case, sends to view template)
    render_content(ERB.new(template_content).result(binding), "text/html")

  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
