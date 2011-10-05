(function() {
  var DEFAULT_PORT, SAMPLE_LENGTH, add_links, app, book_parse, converter, db, db_create, express, fs, lookup, port, sqlite, util;
  express = require('express');
  fs = require('fs');
  converter = new (require('showdown')).Showdown.converter();
  util = require('util');
  sqlite = require('sqlite');
  db = new sqlite.Database();
  DEFAULT_PORT = 1234;
  SAMPLE_LENGTH = 10;
  book_parse = function(list) {
    var contents, file, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      file = list[_i];
      contents = fs.readFileSync(BOOK_DIR + file, "UTF-8");
      _results.push(converter.makeHtml(contents));
    }
    return _results;
  };
  app = express.createServer(express.logger());
  app.set("view options", {
    layout: false
  });
  app.set('view engine', 'coffee');
  app.use(express.static(__dirname + "/public"));
  app.use(express.bodyParser());
  app.register('.coffee', require('coffeekup').adapters.express);
  db_create = function(callback) {
    return db.open("db", function(error) {
      if (error) {
        throw error;
      }
      return db.execute("create table posts (content, author)", function(error) {
        return callback();
      });
    });
  };
  lookup = function(sql, callback) {
    return db.open("db", function(error) {
      if (error) {
        throw error;
      }
      return db.prepare(sql, function(error, statement) {
        if (error) {
          throw error;
        }
        return statement.fetchAll(function(error, rows) {
          if (error) {
            throw error;
          }
          return callback(rows);
        });
      });
    });
  };
  add_links = function(rows) {
    var number, row, _i, _len, _results;
    number = 0;
    _results = [];
    for (_i = 0, _len = rows.length; _i < _len; _i++) {
      row = rows[_i];
      number += 1;
      _results.push(row.link = "/entry/" + number);
    }
    return _results;
  };
  app.get('/', function(request, response) {
    return lookup("select * from posts", function(rows) {
      add_links(rows);
      rows.reverse();
      return response.render('index', {
        posts: rows
      });
    });
  });
  app.get("/entry/:id", function(request, response) {
    var id;
    id = request.params.id;
    return lookup("select * from posts where rowid = " + id, function(rows) {
      return response.render('post', {
        content: rows[0].content,
        author: rows[0].author
      });
    });
  });
  app.get("/edit/entry/:id", function(request, response) {
    var id;
    id = request.params.id;
    return lookup("select * from posts where rowid = " + id, function(rows) {
      return response.render('admin', {
        content: rows[0].content,
        author: rows[0].author,
        action: "/edit/entry/" + id
      });
    });
  });
  app.post("/edit/entry/:id", function(request, response) {
    var author, content, id;
    id = request.params.id;
    content = request.body["new-content"];
    author = request.body["author"];
    return db.open("db", function(error) {
      if (error) {
        throw error;
      }
      return db.execute("update posts set content='" + content + "', author='" + author + "' where rowid = " + id, function() {
        if (error) {
          throw error;
        }
        return response.redirect("/");
      });
    });
  });
  app.get("/admin", function(request, response) {
    return response.render('admin');
  });
  app.post("/admin", function(request, response) {
    var author, content;
    content = request.body["new-content"];
    author = request.body["author"];
    return db_create(function() {
      return db.open("db", function(error) {
        if (error) {
          throw error;
        }
        return db.execute("insert into posts (content, author) values ('" + content + "', '" + author + "')", function(error) {
          if (error) {
            throw error;
          }
          return response.redirect("/");
        });
      });
    });
  });
  port = process.env.PORT || DEFAULT_PORT;
  app.listen(port, function() {
    return console.log("Listening on http://localhost:" + port);
  });
}).call(this);
