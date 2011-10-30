(function() {
  var con_string, db, pg;
  pg = require('pg');
  con_string = process.env.DATABASE_URL || "tcp://grant:a@localhost:5432/bestdb";
  db = new pg.Client(con_string);
  db.connect();
  db.query("create table posts (content varchar(10000), author varchar(20))");
}).call(this);
