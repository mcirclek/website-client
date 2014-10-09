AppView = require('views/appview')

class HeaderView extends AppView
  className: 'navbar navbar-default navbar-fixed-top'

  events:
    'click #login-form .dropdown-menu': 'dropClick'
    'submit form': 'login'
    'click .js-logout': 'logout'

  initialize: ->
    super
    @listenTo Session.me, 'change', @render

  render: ->
    $(@el).html @template 'header', {},
      partials:
        navigation: require('templates/header_navigation')
    return @

  selectLink: (href) ->
    @$('.active').removeClass('active')
    if !href?
      return

    link = @$('a[href$="' + href + '"]')
    link.parent('li').addClass('active')
    link.parents('li.dropdown').addClass('active')

  dropClick: (e) ->
    if @$(e.target).prop('type') != 'submit'
      return false

  login: ->
    unq = @$('.js-unq').val()
    password = @$('.js-password').val()
    Session.login(unq, password)
    .catch (err) =>
      Util.showAlert("Invalid username or password")
    .done()
    return false

  logout: (e) ->
    Session.logout()

module.exports = HeaderView
