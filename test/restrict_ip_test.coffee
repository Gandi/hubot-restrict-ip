# path   = require 'path'
express = require 'express'
sinon   = require 'sinon'
expect  = require('chai').use(require('sinon-chai')).expect
request = require 'supertest'

# ---------------------------------------------------------------------------------
describe 'restrict-ip module', ->

  beforeEach ->
    process.env.PORT = 80800
    app = express()
    app.use express.query()
    app.enable('trust proxy')
    @robot = { router: app }
    @robot.router.get '/endpoint', (req, res) ->
      res.status(200).end('okay')
    

  context 'with no restriction', ->
    beforeEach ->
      require('../scripts/restrict_ip')(@robot)

    it 'deliver the payload', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '192.168.10.1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()

  context 'with no restriction and a blacklist (ipv4)', ->
    beforeEach ->
      process.env.HTTP_IP_BLACKLIST = [ '192.168.10.1' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks if ip is in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '192.168.10.1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 401
          expect(res.text).to.eql 'Not authorized.'
          done()

    it 'delivers if ip is not in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '192.168.10.2')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()

  context 'with no restriction and a blacklist (ipv4 with a CIDR)', ->
    beforeEach ->
      process.env.HTTP_IP_BLACKLIST = [ '192.168.10.1/24' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks if ip is in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '192.168.10.1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 401
          expect(res.text).to.eql 'Not authorized.'
          done()

    it 'delivers if ip is not in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '192.168.11.1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()

  context 'with no restriction and a blacklist (ipv6)', ->
    beforeEach ->
      process.env.HTTP_IP_BLACKLIST = [ '2001:db8::2:1' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks if ip is in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '2001:db8::2:1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 401
          expect(res.text).to.eql 'Not authorized.'
          done()

    it 'delivers if ip is not in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '2001:db8::2:2')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()

  context 'with no restriction and a blacklist (ipv6 with a CIDR)', ->
    beforeEach ->
      process.env.HTTP_IP_BLACKLIST = [ '2001:db8:1234::/48' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks if ip is in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '2001:db8:1234::1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 401
          expect(res.text).to.eql 'Not authorized.'
          done()

    it 'delivers if ip is not in blacklist', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '2001:db8:1235::1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()

  context 'with no restriction and a closed endpoint', ->
    beforeEach ->
      process.env.HTTP_CLOSED_ENDPOINTS = [ '/endpoint' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks access', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '2001:db8:1234::1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 401
          expect(res.text).to.eql 'Not authorized.'
          done()

  context 'with no restriction and a closed regex endpoint', ->
    beforeEach ->
      process.env.HTTP_CLOSED_ENDPOINTS = [ '/end.*' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks access', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '2001:db8:1234::1')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 401
          expect(res.text).to.eql 'Not authorized.'
          done()


  context 'with no restriction and a closed endpoint but a whitelisted ip', ->
    beforeEach ->
      process.env.HTTP_CLOSED_ENDPOINTS = [ '/endpoint' ]
      process.env.HTTP_IP_WHITELIST = [ '10.0.0.0/24' ]
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks access', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '10.0.0.15')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()

  context 'with restriction and an open endpoint', ->
    beforeEach ->
      process.env.HTTP_OPEN_ENDPOINTS = [ '/endpoint' ]
      process.env.HTTP_RESTRICTED = 'yes'
      require('../scripts/restrict_ip')(@robot)

    afterEach ->
      delete process.env.HTTP_IP_BLACKLIST

    it 'blocks access', (done) ->
      request(@robot.router)
        .get('/endpoint')
        .set('X-Forwarded-For', '10.0.0.15')
        .end (err, res) ->
          if err?
            throw err
          expect(res.status).to.eql 200
          expect(res.text).to.eql 'okay'
          done()
