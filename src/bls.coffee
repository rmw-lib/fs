#!/usr/bin/env coffee

import BASE64 from 'urlsafe-base64'
import Bls from 'bls-wasm'
import b64path from './b64path'
import fs from 'fs'
import blake from 'blake3'
import 'at.property'

class Key
  constructor:(@_)->

  @property(
    pubbin:
      get:->
        Buffer.from @_.getPublicKey().serialize()

    pubhash:
      get:->
        blake.hash(@pubbin)

    pubhashpath:
      get:->
        {_path} = @
        if not _path
          @_path = _path = b64path(@pubhash)
        _path

    pubhashb64:
      get:->
        BASE64.encode @pubhash
  )

export default (private_path)=>
  await Bls.init(Bls.BLS12_381)

  if fs.existsSync private_path
    bin = fs.readFileSync private_path
    sec = new Bls.SecretKey()
    sec.deserialize bin
  else
    sec = new Bls.SecretKey()
    sec.setByCSPRNG()
    bin = sec.serialize()
    fs.writeFileSync private_path, bin

  return new Key(sec)


  # console.log sec.serializeToHexStr()
  # console.log bin.length

  # msg = Buffer.from "hello world 12345"
  # sign = sec.sign msg
  # sign = sign.serialize()

  # pbin = sec.getPublicKey().serialize()
  # pb64 = BASE64.encode blake.hash(pbin)
  # console.log blake.hash(pbin).length, pb64

  # s = new Bls.Signature()
  # s.deserialize sign
  #
  # pub = new Bls.PublicKey()
  # pub.deserialize(pbin)
  # console.log pub.verify s, msg
