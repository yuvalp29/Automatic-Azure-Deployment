const port = 80
var os = require("os")

require('http')
  .createServer((req, res) => {
    console.log('url:', req.url)
    res.end(os.hostname())
  })
  .listen(port, (error)=>{
    console.log(`server is running on ${port}`)
  })
