
http     = require 'http'
hostname = '127.0.0.1'
port     = 3000
server   = http.create-server (req, res) !->
    res.statusCode = 200
    res.setHeader 'Content-Type' 'text/plain'
    res.end 'Hello World\n'

server.listen port, hostname, !->
    console.log 'server running at ${hostname}:{$port}'




