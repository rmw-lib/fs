#!/usr/bin/env coffee
import dump from '@rmw/fs/dump'
import load from '@rmw/fs/load'
import fs from 'fs'
import {thisdir} from '@rmw/thisfile'
import {dirname} from 'path'
import path from 'path'
import Bls from '@rmw/fs/bls'
import os from 'os'

do =>
  bls_private = path.join os.homedir(), ".config/rmw/id_bls"
  r = await dump dirname(thisdir `import.meta`), await Bls(bls_private)
  for i from load r
    console.log i
    # if not fs.existsSync(i)
    #   console.log i
