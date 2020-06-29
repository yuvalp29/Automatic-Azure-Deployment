// Variables and Constants
const port = 9090
var request = require('request');
var http = require('http');
var ip = require("ip");
var os = require("os")
var dns = '';
var publicIP = '';

request('http://169.254.169.254/latest/meta-data/public-hostname', function (error, response, body) {
   if (!error && response.statusCode == 200) {
       dns = body;
   }
})

request('http://169.254.169.254/latest/meta-data/public-ipv4', function (error, response, body) {
   if (!error && response.statusCode == 200) {
       publicIP = body;
   }
})

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.write('Hostname: ' + os.hostname() + '<br/>');
  res.write('DNS: ' + `${dns}` + '<br/>');
  res.write('Public IP: ' + `${publicIP}` + '<br/>');
  res.write('Private IP: ' + ip.address() + '<br/>');
  res.end();
}).listen(port, (error)=>{console.log(`server is running on ${port}`)})
