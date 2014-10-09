User = require('models/user')

class Session
  constructor: ->
    token = $.cookie('token')
    if token
      [unq, token] = token.split(':')
    @me = new User({ unq })

    if unq?
      @me.fetch() #TODO parameters
      .catch =>
        @clear()
      .done()

  clear: ->
    $.removeCookie('token')
    @me.clear()

  login: (unq, password) ->
    Backbone.ajax
      type: 'POST'
      url: '/1/auth/login'
      data: { unq, password }
    .then (me) =>
      @me.set(me, { parse: true })

  logout: ->
    Backbone.ajax
      type: 'POST'
      url: '/1/auth/logout'
    .then =>
      @me.clear()

  loggedIn: ->
    return !@me.isNew()

module.exports = Session
