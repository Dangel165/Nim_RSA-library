import types
import std/[strutils, bigints, base64]

proc toString*(key: RSAPublicKey): string =
  let nStr = key.n.toString()
  let nPreview = if nStr.len > 64: nStr[0..63] & "..." else: nStr
  return "PublicKey(n=" & nPreview & ", e=" & $key.e & ")"

proc toString*(key: RSAPrivateKey): string =
  let nStr = key.n.toString()
  let nPreview = if nStr.len > 64: nStr[0..63] & "..." else: nStr
  return "PrivateKey(n=" & nPreview & ", d=***HIDDEN***)"

proc toHexString*(data: seq[byte]): string =
  result = ""
  for b in data:
    result.add(b.toHex(2))

proc fromHexString*(hexStr: string): seq[byte] =
  result = newSeq[byte](hexStr.len div 2)
  for i in countup(0, hexStr.len - 1, 2):
    result[i div 2] = byte(parseHexInt(hexStr[i..i+1]))

proc toBase64*(data: seq[byte]): string =
  return encode(cast[string](data))

proc fromBase64*(b64Str: string): seq[byte] =
  return cast[seq[byte]](decode(b64Str))

proc getKeySize*(key: RSAPublicKey): int =
  return key.n.toString().len * 4

proc getKeySize*(key: RSAPrivateKey): int =
  return key.n.toString().len * 4
