# Description
#   This is a script that will check the Hotlight status at Krispy Kreme sotores.
#
# Dependencies:
#   "hotlight-node": "latest"
#
# Commands:
#   hubot my krispy zip is (zipcode) - sets your zipcode in the brain
#   hubot my krispy stores are (store ids) - sets your sotore ids
#   hubot krispy status <zipcode or store ids> -gets the status of hotlight for locations
#   hubot hotlight me <zipcode or store ids> -  gets the currently on hotlights for locations
#   dougnuts - if it can figure out your zipcode or store ids it gets the hotlight status
#
# Author:
#   jamsajones


Hotlight = require 'hotlight'

params = (msg)->
  p = {}
  if msg.match[1]?
    if msg.match[1].match /\d{5}/
      p.zipcode = msg.match[1]
    else
      p.locations = msg.match[1]
  else
    if msg.message.user.hotlight_zip?
      p.zipcode = msg.message.user.hotlight_zip
    else if msg.message.user.hotlight_stores?
      p.locations = msg.message.user.hotlight_stores
  p

hots = (msg) ->
  try
    hl = new Hotlight
    hl.once "hots", (locations) ->
      if locations.length > 0
        (msg.send "#{location.title} is hot" for location in locations)
      else
        msg.send "Oh no! There are no Hotlights on nearby."
    hl.get_hots params(msg)
  catch error
    console.log error
    hl.removeAllListeners 'hots'

status = (msg) ->
  try
    hl = new Hotlight
    hl.once "status", (locations)->
      for location in locations
        hot_or_not = (if location.hotLightOn == 1 then 'HOT! :D' else 'not hot. :(')
        msg.send "#{location.title} is #{ hot_or_not }"

    hl.status params(msg)
  catch error
    console.log error
    hl.removeAllListeners 'hots'

module.exports = (robot) ->
  robot.respond /my krispy zip is (\d{5})/i, (msg) ->
    if msg.match[1].match /\d{5}/
      msg.message.user.hotlight_zip = msg.match[0]

  robot.respond /my krispy stores are is (.*)/i, (msg) ->
    if msg.match[1]
      msg.message.user.hotlight_stores = msg.match[0]

  robot.respond /hotlight me (.*)/i, (msg) ->
    hots msg

  robot.respond /krispy status (.*)/i, (msg) ->
    status msg

  robot.hear /dougnuts/i, (msg) ->
    hots msg