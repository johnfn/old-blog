express = require 'express'
fs = require 'fs'
converter = new (require 'showdown').Showdown.converter()
util = require 'util'
sqlite = require 'sqlite'

db = new sqlite.Database()

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

db_create = (callback) ->
  db.open "db", (error) ->
    throw error if error

    db.execute "create table posts (content)", (error) ->
      # throw error if error

      callback()

lookup = (sql, callback) ->
  db.open "db", (error) ->
    throw error if error

    db.prepare sql, (error, statement) ->
      throw error if error
      statement.fetchAll (error, rows) ->
        throw error if error

        callback(rows)

trim_contents = (rows) ->
  for row in rows
    row.content = row.content.substring(0, SAMPLE_LENGTH) + "..."

add_links = (rows) ->
  number = 0
  for row in rows
    number += 1
    row.link = "/entry/#{number}"


#TODO: Translate to HTML first.
app.get '/', (request, response) ->
  lookup "select * from posts", (rows) ->
    trim_contents rows
    add_links rows

    response.render 'index', posts : rows

app.get "/entry/:id", (request, response) ->
  id = request.params.id
  lookup "select * from posts where rowid = #{id}", (rows) ->
    response.render 'post', content: rows[0].content

app.get "/admin", (request, response) ->
  response.render 'admin'

#TODO: Insert HTML as well...maybe?
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
