// Useless express app, so that scalingo is happy.

var express = require('express')
var app = express()

var server = app.listen(process.env.PORT || 3000, function () {
  var host = server.address().address
  var port = server.address().port
  console.log('App listening at http://%s:%s', host, port)
})