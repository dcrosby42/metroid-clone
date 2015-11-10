http = require('http')
fs = require('fs')

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

updateData = (d, obj) ->
  for o in obj._objects
    for k,v of o
      d[k] ?= []
      d[k].push v

dumpData = (d) ->
  for k,v of d
    fname = "#{k}_values.txt"
    out = fs.createWriteStream(fname)
    for x in v
      out.write("#{x}\n")
    out.end()
    console.log "Wrote #{fname}"

Data = {}
server = http.createServer (req,res) ->

    # console.dir req.param

    if req.method == 'POST'
        # console.log("POST")
        body = ''
        req.on 'data', (data) ->
          body += data
        req.on 'end', ->
          obj = JSON.parse(body)
          console.log obj
          if obj._action? and obj._action == 'cut'
            dumpData(Data)
          else
            updateData(Data, obj)
          # console.log("Body: " + body)
        res.writeHead 200, 'Content-Type': 'text/html', 'Access-Control-Allow-Origin': '*'
        res.end('post received')

port = 3100
# host = '127.0.0.1'
host = '0.0.0.0'
server.listen(port, host)
console.log('Listening at http://' + host + ':' + port)
