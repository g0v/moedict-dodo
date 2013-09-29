#!/usr/bin/env lsc
require! fs
for {title, heteronyms} in JSON.parse(fs.read-file-sync \../dict-revised.pua.json \utf8)
  for {definitions} in heteronyms
    for {quote} in definitions | quote
      for q in quote
        console.log "#q\t#title"
