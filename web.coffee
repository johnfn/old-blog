express = require 'express'
fs = require 'fs'
converter = new (require 'showdown').Showdown.converter()
util = require 'util'

DEFAULT_PORT = 1234

book_parse = (list) ->
  for file in list
    contents = fs.readFileSync BOOK_DIR + file, "UTF-8"
    converter.makeHtml(contents)

app = express.createServer express.logger()

app.set "view options", layout : false
app.set 'view engine', 'coffee'

app.use(express.static __dirname + "/public")

app.register '.coffee', require('coffeekup').adapters.express

app.get '/', (request, response) ->
  response.render 'index', posts : [ (title: "A title", desc: "This post changed my life many times over.", date: "This post was recent.")
                                   , (title: "Rawral", desc: "This post describes the many different ways of typing rawr. Very informative!", date: "This post was herp.")
                                   ]

port = process.env.PORT || DEFAULT_PORT
app.listen port, () ->
  console.log "Listening on http://localhost:#{port}"
