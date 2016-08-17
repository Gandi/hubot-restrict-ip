# Description:
#   Express middleware that will permit to filter
#   who has access to the http endpoints of your hubot bot
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

IP = require 'range_check'


module.exports = (robot) ->

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
      if IP.isRange(it)
        if IP.inRange(ip, it)
          back = true
          break
      else
        if it is ip
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
    endpointOk(endpoint) and ipOk(ip)

  restrict_ip = (req, res, next) ->
    endpoint = req.url
    if isPermitted(endpoint, req.ip)
      next()
    else
      res.status(401).end(HTTP_UNAUTHORIZED_MESSAGE)

  robot.router.stack.splice 2, 0, {
    route: '',
    handle: restrict_ip
  }
