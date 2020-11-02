export default (i)=>
  b = Buffer.allocUnsafe 6
  b.writeUIntBE i, 0, 6
  b
