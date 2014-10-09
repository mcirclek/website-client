Session = require('models/session')
Controller = require('controller')

# set up analytics
require('lib/backbone.analytics')
# useful errors
require('lib/error')

config = require('config')
xbbcode = require('ext/xbbcode')

$ ->
  $('#modal').modal(show: false)
  ajax = Backbone.ajax
  Backbone.ajax = (options) ->
    options.data ?= {}
    if $.cookie('token')
      if _.isString(options.data)
        data = JSON.parse(options.data)
        data.token = $.cookie('token')
        options.data = JSON.stringify(data)
      else
        options.data.token = $.cookie('token')

    Promise.resolve(ajax(options))
    .catch (e) ->
      err = Error.AjaxError(e)
      if err.status == 401
        Session.clear()
        #TODO something else

      throw err

  window.Util = require('util')
  window.Session = new Session

  if config.SENTRY_DSN
    Raven.config config.SENTRY_DSN,
      includePaths: [
        /app\.js/
      ]
    .install()

    Promise.onPossiblyUnhandledRejection (err, promise) =>
      Raven.captureException err,
        extras:
          fromUnhandledPromise: true

  if config.GA_ID
    ga('create', config.GA_ID, 'auto')

  Promise.longStackTraces()

  Handlebars.registerHelper 'date', (date, format = 'YYYY-MM-DD HH:mm') ->
    moment(date).format(format)

  Handlebars.registerHelper 'bbcode', (text) ->
    result = xbbcode.process({ text })
    return result.html.replace(/\n/g, '<br />')

  controller = window.Controller = new Controller

  Backbone.history.start()
