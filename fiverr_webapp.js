const port = 80
require('http')
  .createServer((req, res) => {
    console.log('url:', req.url)
    res.end('hello world')
  })
  .listen(port, (error)=>{
    console.log(`server is running on ${port}`)
  })
