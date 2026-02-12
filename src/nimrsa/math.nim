import std/[random, bigints]
import types

proc modPow*(base, exp, modulus: BigInt): BigInt =
  result = powmod(base, exp, modulus)

proc extendedGCD*(a, b: BigInt): tuple[gcd, x, y: BigInt] =
  if b == initBigInt(0):
    return (a, initBigInt(1), initBigInt(0))
  let (gcd, x1, y1) = extendedGCD(b, a mod b)
  let x = y1
  let y = x1 - (a div b) * y1
  return (gcd, x, y)

proc modInverse*(a, m: BigInt): BigInt =
  let (gcd, x, _) = extendedGCD(a, m)
  if gcd != initBigInt(1):
    raise newException(RSAKeyError, "Modular inverse does not exist")
  return (x mod m + m) mod m

proc isProbablePrime*(n: BigInt, k: int = 40): bool =
  if n <= initBigInt(1): return false
  if n == initBigInt(2) or n == initBigInt(3): return true
  if (n and initBigInt(1)) == initBigInt(0): return false
  
  var d = n - initBigInt(1)
  var r = 0
  while (d and initBigInt(1)) == initBigInt(0):
    d = d shr 1
    r += 1
  
  randomize()
  for _ in 0..<k:
    let a = initBigInt(rand(2 .. 1000000)) mod (n - initBigInt(4)) + initBigInt(2)
    var x = powmod(a, d, n)
    
    if x == initBigInt(1) or x == n - initBigInt(1):
      continue
    
    var continueOuter = false
    for _ in 0..<r-1:
      x = (x * x) mod n
      if x == n - initBigInt(1):
        continueOuter = true
        break
    
    if not continueOuter:
      return false
  
  return true

proc generateProbablePrime*(bits: int): BigInt =
  randomize()
  while true:
    var candidate = initBigInt(0)
    for i in 0..<bits:
      if rand(1) == 1:
        candidate = candidate or (initBigInt(1) shl i)
    
    candidate = candidate or (initBigInt(1) shl (bits - 1))
    candidate = candidate or initBigInt(1)
    
    let smallPrimes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    var isDivisible = false
    for p in smallPrimes:
      if candidate mod initBigInt(p) == initBigInt(0) and candidate != initBigInt(p):
        isDivisible = true
        break
    
    if isDivisible:
      continue
    
    if isProbablePrime(candidate):
      return candidate

proc gcd*(a, b: BigInt): BigInt =
  var x = a
  var y = b
  while y != initBigInt(0):
    let temp = y
    y = x mod y
    x = temp
  return x
