express = require 'express'
fs = require 'fs'
converter = new (require 'showdown').Showdown.converter()
util = require 'util'
sqlite = require 'sqlite'

db = new sqlite.Database()

DEFAULT_PORT = 1234

book_parse = (list) ->
  for file in list
    contents = fs.readFileSync BOOK_DIR + file, "UTF-8"
    converter.makeHtml(contents)

app = express.createServer express.logger()

app.set "view options", layout : false
app.set 'view engine', 'coffee'

app.use(express.static __dirname + "/public")
app.use express.bodyParser()

app.register '.coffee', require('coffeekup').adapters.express

db_create = (callback) ->
  db.open "db", (error) ->
    throw error if error

    db.execute "create table posts (content)", (error) ->
      # throw error if error

      callback()

app.get '/', (request, response) ->
  response.render 'index', posts : [ (title: "The Importance of Doing Important Things", desc: "This post changed my life many times over.", date: "This post was recent.")
                                   , (title: "Rawral", desc: "This post describes the many different ways of typing rawr. Very informative!", date: "This post was herp.")
                                   ]

app.get "/entry/:id", (request, response) ->
  id = request.params.id
  response.render 'post', title: "This is a blog title", content: "Bogus content goes here."

app.get "/admin", (request, response) ->
  console.log "ok..."
  response.render 'admin'

app.get "/allposts", (request, response) ->
  db.open "db", (error) ->
    throw error if error

    db.prepare "select * from posts", (error, statement) ->
      throw error if error
      statement.fetchAll (error, row) ->
        throw error if error

        response.render "post", content: row[0].content

app.post "/admin", (request, response) ->
  content = request.body["new-content"]

  db_create ->
    db.open "db", (error) ->
      throw error if error

      db.execute "insert into posts (content) values ('#{content}')", (error) ->
        throw error if error

      response.redirect("/")

port = process.env.PORT || DEFAULT_PORT
app.listen port, () ->
  console.log "Listening on http://localhost:#{port}"
