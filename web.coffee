express = require 'express'
pg = require 'pg'
fs = require 'fs'
converter = new (require 'showdown').Showdown.converter()
util = require 'util'

con_string = process.env.DATABASE_URL || "tcp://grant:a@localhost:5432/bestdb"

db = new pg.Client(con_string)
db.connect()

DEFAULT_PORT = 1234

SAMPLE_LENGTH = 10

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

###
db_create = (callback) ->
  db.open "db", (error) ->
    throw error if error

    db.execute "create table posts (content, author)", (error) ->
      # throw error if error

      callback()
###

lookup = (query, cb) ->
  query = db.query query
  results = []

  query.on 'row', (row) -> results.push row
  query.on 'end', -> cb results

add_links = (rows) ->
  number = 0
  for row in rows
    number += 1
    row.link = "/entry/#{number}"


#TODO: Translate to HTML first.
app.get '/', (request, response) ->
  lookup "select * from posts", (rows) ->
    add_links rows
    rows.reverse()

    response.render 'index', posts : rows

app.get "/entry/:id", (request, response) ->
  id = request.params.id
  lookup "select * from posts where rowid = #{id}", (rows) ->
    response.render 'post', content: rows[0].content, author: rows[0].author

app.get "/edit/entry/:id", (request, response) ->
  id = request.params.id
  lookup "select * from posts where rowid = #{id}", (rows) ->
    response.render 'admin', content: rows[0].content, author: rows[0].author, action: "/edit/entry/#{id}"

app.post "/edit/entry/:id", (request, response) ->
  id = request.params.id
  content = request.body["new-content"]
  author = request.body["author"]

  db.query "update posts set content='#{content}', author='#{author}' where rowid = #{id}"
  throw error if error

  response.redirect "/"

app.get "/admin", (request, response) ->
  response.render 'admin'

#TODO: Insert HTML as well...maybe?
app.post "/admin", (request, response) ->
  content = request.body["new-content"]
  author = request.body["author"]

  db.query "insert into posts (content, author) values ('#{content}', '#{author}')"
  response.redirect("/")

port = process.env.PORT || DEFAULT_PORT
app.listen port, () ->
  console.log "Listening on http://localhost:#{port}"
