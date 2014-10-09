CalendarView = require('views/calendar')
HeaderView = require('views/header')
StaticView = require('views/static')

Event = require('models/event')

class Controller extends Backbone.Router
  initialize: ->
    @view = null
    @headerView = new HeaderView()
    $('#header').html(@headerView.render().el)

    @events = new Event.MasterCollection()
    @events.ensureRange(moment({ day: 1 }).subtract(1, 'weeks'), moment({ day: 1 }).add(1, 'months').add(1, 'weeks'))

  execute: (args...) ->
    if !Session.loggedIn() || Session.me.synced
      super(args...)
    else
      @listenToOnce Session.me, 'change:synced', =>
        super(args...)

  routes:
    '': 'home'
    'calendar(/:year/:month)': 'calendar'
    'p/*page': 'page'
    '*other': 'notfound'

  switchView: (view) ->
    @view = view
    $('#content').html(view.render().el)

  home: ->
    @headerView.selectLink()
    @switchView(new StaticView(name: 'home'))

  calendar: (year = moment().year(), month) ->
    if month?
      month--
    else
      month = moment().month()

    @headerView.selectLink('calendar')

    @switchView(new CalendarView({ model: @events, year, month }))

    first = moment({ year, month, day: 1 })
    end = moment(first).add(1, 'months')
    @events.ensureRange(first, end)
    start = moment(first).subtract(1, 'months').subtract(1, 'weeks')
    end.add(1, 'months').add(1, 'weeks')
    # make sure there is no wait to go backwards or forwards
    @events.ensureRange(start, end)

  page: (name) ->
    try
      @headerView.selectLink('p/' + name)
      @switchView(new StaticView(name: 'pages/' + name))
    catch
      @switchView(new StaticView(name: 'notfound'))

  notfound: (link) ->
    @headerView.selectLink(link)
    @switchView(new StaticView(name: 'notfound'))

module.exports = Controller
