# Handles routing, i.e. matching a route with a controller's method and calling it to render a view.
#
# Note that Backbone's routing is NOT used (do not call Backbone.history.start or any of its methods) and there is no
# idea of listening to hash changes at the moment.
#
# This class only handles very simple routing, i.e. mapping a fixed route string (without any possible parameters) to
# the respective controller method. More advanced routing libraries could be added here.
class Router
  constructor: ->
    @routes = {}

    # This class handles page loading which is triggered by hist.push, for example
    mediator.subscribe 'must-load-fragment', (fragment, queueName, onSuccess) =>
      view = @renderRoute(fragment)

      if not view?.getHtmlElement?
        throw "No view returned, does controller method return the view? (view=#{view})"

      if onSuccess?
        onSuccess(view)

  addRoute: (pattern, method) ->
    if pattern of @routes
      throw "Route '#{pattern}' already exists"

    @routes[pattern] = method

  renderRoute: (pattern) ->
    if pattern not of @routes
      throw "Route '#{pattern}' not found, is the controller loaded?"

    # Call the controller's method here (which must return a view)
    view = @routes[pattern]()

    if not view
      throw "Controller did not return a view for route '#{pattern}'"

    existingPage = view.findHtmlElement('[data-role="page"]')

    if existingPage.length > 1
      throw 'Expected exactly 0 or 1 jQM pages in rendered view'
    else if existingPage.length is 0
      existingPage = view.getHtmlElement()
      existingPage.attr('data-role', 'page')

    return view

module.exports = new Router()