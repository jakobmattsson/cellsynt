https = require 'https'

simplePOST = (args, callback) ->

  urlencode = (obj) -> Object.keys(obj).map((key) -> key + '=' + encodeURIComponent(obj[key])).join('&')

  options = {
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
    hostname: args.hostname
    port: args.port || 443
    path: args.path
    method: 'POST'
  }

  resultBody = ""

  req = https.request options, (res) ->
    res.setEncoding('utf8')
    res.on 'data', (chunk) -> resultBody += chunk
    res.on 'end', -> callback(null, resultBody)

  req.on 'error', (e) -> callback(e)
  req.write(urlencode(args.data))
  req.end()



exports.create = ({ username, password }) ->

  send = (data, callback) ->
    form = {
      username
      password
      destination: if Array.isArray(data.destination) then data.destination.join(',') else data.destination
      originator: data.originator
      text: data.text
      originatortype: 'alpha'
      charset: 'UTF-8'
      type: data.type || 'text'
      allowconcat: data.allowconcat || 6
    }

    if !form.originator? || form.originator.length < 1 || form.originator.length > 11
      return callback(null, new Error("Must have originator with 1-11 characters"))
    if !form.originator.match(/^[a-zA-Z0-9]*$/)
      return callback(null, new Error("Can only use a-z, A-Z and 0-9 in the originator"))
    if form.allowconcat < 1 || form.allowconcat > 6
      return callback(null, new Error("allowconcat must ba a number between 1 and 6"))
    if !(form.type in ['text', 'unicode'])
      return callback(null, new Error("type must be text or unicode"))

    simplePOST
      hostname: 'se-1.cellsynt.net'
      path: '/sms.php'
      data: form
    , (err, data) ->
      return callback(err) if err?
      return callback(data) if (data || '').slice(0, 4) != 'OK: '
      callback()

  { send }
