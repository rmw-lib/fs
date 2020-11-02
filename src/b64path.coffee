import BASE64 from 'urlsafe-base64'

export default (bin)=>
  b64 = BASE64.encode(bin)
  [...b64[...5],b64[5..]].join('/')

