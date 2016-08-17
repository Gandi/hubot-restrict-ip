# Description:
#   Express middleware that will permit to filter who has access to the http endpoints of your hubot bot
#
# Coniguration:
#   HTTP_RESTRICTED
#   HTTP_ENDPOINTS_PUBLIC
#   HTTP_IP_WHITELIST
#   HTTP_IP_BLACKLIST
#   HTTP_OPEN_ENDPOINTS
#   HTTP_CLOSED_ENDPOINTS
#   HTTP_UNAUTHORIZED_MESSAGE
#
# Author:
#   mose

IP = require 'ip'
require('source-map-support').install {
  handleUncaughtExceptions: false,
  environment: 'node'
}

HTTP_RESTRICTED = process.env.HTTP_RESTRICTED?
HTTP_ENDPOINTS_PUBLIC = process.env.HTTP_ENDPOINTS_PUBLIC?
HTTP_IP_WHITELIST = if process.env.HTTP_IP_WHITELIST?
    process.env.HTTP_IP_WHITELIST.split ','
  else
    [ ]
HTTP_IP_BLACKLIST = if process.env.HTTP_IP_BLACKLIST?
    process.env.HTTP_IP_BLACKLIST.split ','
  else
    [ ]
HTTP_OPEN_ENDPOINTS = if process.env.HTTP_OPEN_ENDPOINTS?
    process.env.HTTP_OPEN_ENDPOINTS.split(',').map (ep) -> new RegExp("^#{ep}$") 
  else
    [ ]
HTTP_CLOSED_ENDPOINTS = if process.env.HTTP_CLOSED_ENDPOINTS?
    process.env.HTTP_CLOSED_ENDPOINTS.split(',').map (ep) -> new RegExp("^#{ep}$")
  else
    [ ]
HTTP_UNAUTHORIZED_MESSAGE = process.env.HTTP_UNAUTHORIZED_MESSAGE or 'Not authorized.'

module.exports = (robot) ->

  endpointOk = (endpoint) ->
    ( HTTP_RESTRICTED and
      endpointIn(endpoint, HTTP_OPEN_ENDPOINTS) and
      not endpointIn(endpoint, HTTP_CLOSED_ENDPOINTS) ) or
    not endpointIn(endpoint, HTTP_CLOSED_ENDPOINTS)

  ipOk = (ip) ->
    ( HTTP_RESTRICTED and 
      ipIn(ip, HTTP_IP_WHITELIST) and 
      not ipIn(ip, HTTP_IP_BLACKLIST) ) or
    not ipIn(ip, HTTP_IP_BLACKLIST)

  ipIn = (ip, list) ->
    back = false
    for it in list
      if it.indexOf('/') > -1
        if IP.cidrSubnet(it).contains ip
          back = true
          break
      else
      if IP.isEqual(it, ip)
        back = true
        break
    back

  endpointIn = (endpoint, list) ->
    back = false
    for it in list
      if it.test ip
        back = true
        break
    back

  isPermitted = (endpoint, ip) ->
    ( HTTP_ENDPOINTS_PUBLIC and endpointOk(endpoint) ) or 
    ( endpointOk(endpoint) and ipOk(ip) )


  robot.router.use (req, res, next) ->
    endpoint = req.url
    ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
    if isPermitted(endpoint, ip)
      next()
    else
      res.status(401).end(HTTP_UNAUTHORIZED_MESSAGE)
