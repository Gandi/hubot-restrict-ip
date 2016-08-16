require('source-map-support').install {
  handleUncaughtExceptions: false,
  environment: 'node'
}

Helper = require('hubot-test-helper')

# helper loads a specific script if it's a file
helper = new Helper('../scripts/restrict_ip.coffee')

# path   = require 'path'
# sinon  = require 'sinon'
expect = require('chai').use(require('sinon-chai')).expect

room = null

# ---------------------------------------------------------------------------------
describe 'restrict-ip module', ->

  pending 'do teh magic'
