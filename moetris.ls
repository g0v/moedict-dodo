ALL = Words!

match-cache = {}

cur = "零星燎原拆陋政時雨潤物建新府"[Math.floor(Math.random! * 14)]
while cur
  seen = {}
  scores = []
  blacklist = {"": true}
  console.log "=========================\n#cur"
  for c in cur
    results = match-cache[c] ||= ALL.match(//[^"]*#c[^"]*//g)
    for r in results
      seen[r] ?= 0
      score = ++seen[r]
      if r.length > (score + 1)
        scores[score] ?= ""
        scores[score] += "#r\n"
      else blacklist[r] = true
  cands = []
  until cands?length => cands = [ s for s in (scores.pop! ? '') / "\n" | not blacklist[s] ]
  c2 = []
  until c2?length or !scores.length => c2 = [ s for s in (scores.pop! ? '') / "\n" | not blacklist[s] ]
  cands ++= c2
  console.log "Candidates:\n#cands\n"
  pick = ""
  for cand in cands
    for c in cur => cand -= //#c//
    pick += cand
  p = pick[Math.floor Math.random! * pick.length]
  cur += p

function Words => require(\fs).read-file-sync(\letris.lsz \utf8) - /[；，]/g
