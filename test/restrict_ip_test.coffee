require('source-map-support').install {
  handleUncaughtExceptions: false,
  environment: 'node'
}

Helper = require('hubot-test-helper')

# helper loads a specific script if it's a file
helper = new Helper('../scripts/restrict_ip.coffee')

# path   = require 'path'
sinon   = require 'sinon'
expect  = require('chai').use(require('sinon-chai')).expect
request = require 'supertest'

room = null

# ---------------------------------------------------------------------------------
describe 'restrict-ip module', ->

  beforeEach ->
    process.env.PORT = 80800
    room = helper.createRoom()
    room.robot.logger.info = sinon.stub()
    room.robot.router.enable('trust proxy')
    room.robot.router.get '/endpoint', (req, res) ->
      res.status(200).end('okay')

  afterEach ->
    room.destroy()

  context 'with no restriction', ->

    it 'deliver the payload', (done) ->
      request(room.robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '192.168.10.1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()
