#!/usr/bin/env lsc
require! <[ fs path express ]>
app = express!
fd = fs.openSync(path.join(process.cwd(), 'log.txt'), 'a')
app.get '/', (req, res) ->
  fs.writeSync(fd, "#{ req.query.log }\n") if req.query.log
  res.type \application/javascript
  res.end "#{ req.query.callback }({});"
app.listen 8080
