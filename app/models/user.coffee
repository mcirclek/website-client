AppModel = require('models/appmodel')

class User extends AppModel
  typeName: 'User'
  urlRoot: '/1/users'
  idAttribute: 'unq'

  defaults:
    unq: null
    access_level: 0
    first_name: ''
    last_name: ''
    id_committee: 0
    committee_name: ''
    committee_position: ''

class UserCollection extends Backbone.Collection
  model: User

User.Collection = UserCollection

module.exports = User
