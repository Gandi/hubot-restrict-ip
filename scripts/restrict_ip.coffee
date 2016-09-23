# Description:
#   Express middleware that will permit to filter
#   who has access to the http endpoints of your hubot bot
#
# Coniguration:
#   HTTP_RESTRICTED
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
  HTTP_IP_WHITELIST = if process.env.HTTP_IP_WHITELIST?
    process.env.HTTP_IP_WHITELIST.split ','
  else
    [ ]
  HTTP_IP_BLACKLIST = if process.env.HTTP_IP_BLACKLIST?
    process.env.HTTP_IP_BLACKLIST.split ','
  else
    [ ]
  HTTP_OPEN_ENDPOINTS = if process.env.HTTP_OPEN_ENDPOINTS?
    process.env.HTTP_OPEN_ENDPOINTS.split(',').map (ep) ->
      new RegExp("^#{ep.replace(/\//, '\\/')}$")
  else
    [ ]
  HTTP_CLOSED_ENDPOINTS = if process.env.HTTP_CLOSED_ENDPOINTS?
    process.env.HTTP_CLOSED_ENDPOINTS.split(',').map (ep) ->
      new RegExp("^#{ep.replace(/\//, '\\/')}$")
  else
    [ ]
  HTTP_UNAUTHORIZED_MESSAGE = process.env.HTTP_UNAUTHORIZED_MESSAGE or 'Not authorized.'

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
      if it.test endpoint
        back = true
        break
    back

  isPermitted = (endpoint, ip) ->
    ( endpointIn(endpoint, HTTP_OPEN_ENDPOINTS) and not
      endpointIn(endpoint, HTTP_CLOSED_ENDPOINTS) ) or
    ( not HTTP_RESTRICTED and
      not endpointIn(endpoint, HTTP_CLOSED_ENDPOINTS) and
      not ipIn(ip, HTTP_IP_BLACKLIST) ) or
    ( ipIn(ip, HTTP_IP_WHITELIST) and
      not ipIn(ip, HTTP_IP_BLACKLIST) )

  restrict_ip = (req, res, next) ->
    endpoint = req.url
    if isPermitted(endpoint, req.ip)
      next()
    else
      robot.logger.warning "Denied access to #{req.ip}."
      res.status(401).end(HTTP_UNAUTHORIZED_MESSAGE)

  robot.router.stack.splice 2, 0, {
    route: '',
    handle: restrict_ip
  }
