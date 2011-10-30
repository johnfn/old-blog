var pg = require('pg')
  , connectionString = process.env.DATABASE_URL ||  "tcp://grant:a@localhost:5432/bestdb"
  , client
  , query;

client = new pg.Client(connectionString);
client.connect();
query = client.query("create table posts (content varchar(10000), author varchar(20))");
query.on('end', function() { client.end(); });
