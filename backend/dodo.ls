#!/usr/bin/env lsc
require! <[ fs path express ]>
app = express!
log = fs.readFileSync path.join(process.cwd(), 'log.txt'), \utf8
fd = fs.openSync(path.join(process.cwd(), 'log.txt'), 'a')
app.get '/', (req, res) ->
  if req.query.log
    fs.writeSync(fd, req.query.log)
    log += req.query.log
  payload = {}
  if req.query.offset
    payload.delta = log.substr req.query.offset
  res.type \application/javascript
  res.end "#{ req.query.callback }(#{ JSON.stringify payload });"
app.listen 8080
