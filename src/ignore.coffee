import fs from 'fs'
import _ignore from 'ignore'
import {join} from 'path'

export default (dirpath)=>
  ignore_path = join(dirpath,".rmw.ignore")
  if fs.existsSync ignore_path
    t = []
    for i in (fs.readFileSync ignore_path, "utf8").split("\n")
      i = i.trim()
      if i and not i.startsWith "#"
        t.push i
    ig = _ignore().add t
    dirpath_len = 1+dirpath.length
    return (rpath)=>
      p = rpath[dirpath_len..]
      if p == ".rmw"
        return true
      ig.ignores(p)
  => false
