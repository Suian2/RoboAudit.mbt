///|
fn rotr(value : UInt, bits : Int) -> UInt {
  (value >> bits) | (value << (32 - bits))
}

///|
let sha256_constants : FixedArray[UInt] = [
  0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU, 0x59f111f1U, 0x923f82a4U,
  0xab1c5ed5U, 0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U, 0x72be5d74U, 0x80deb1feU,
  0x9bdc06a7U, 0xc19bf174U, 0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU, 0x2de92c6fU,
  0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU, 0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U,
  0xc6e00bf3U, 0xd5a79147U, 0x06ca6351U, 0x14292967U, 0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU,
  0x53380d13U, 0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U, 0xa2bfe8a1U, 0xa81a664bU,
  0xc24b8b70U, 0xc76c51a3U, 0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U, 0x19a4c116U,
  0x1e376c08U, 0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU, 0x682e6ff3U,
  0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U, 0x90befffaU, 0xa4506cebU, 0xbef9a3f7U,
  0xc67178f2U,
]

///|
fn append_sha256_length(message : Array[Byte], original_length : Int) -> Unit {
  message.push(b'\x80')
  while message.length() % 64 != 56 {
    message.push(b'\x00')
  }
  let bit_length = original_length.to_uint64() * 8UL
  for shift in [56, 48, 40, 32, 24, 16, 8, 0] {
    message.push((bit_length >> shift).to_byte())
  }
}

///|
fn sha256_words(input : Bytes) -> Array[UInt] {
  let message = input.to_array()
  let original_length = message.length()
  append_sha256_length(message, original_length)
  let state : Array[UInt] = [
    0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU, 0x510e527fU, 0x9b05688cU,
    0x1f83d9abU, 0x5be0cd19U,
  ]
  let mut offset = 0
  while offset < message.length() {
    let schedule = FixedArray::make(64, 0U)
    for index in 0..<16 {
      let base = offset + index * 4
      schedule[index] = (message[base].to_uint() << 24) |
        (message[base + 1].to_uint() << 16) |
        (message[base + 2].to_uint() << 8) |
        message[base + 3].to_uint()
    }
    for index in 16..<64 {
      let x = schedule[index - 15]
      let y = schedule[index - 2]
      let sigma0 = rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3)
      let sigma1 = rotr(y, 17) ^ rotr(y, 19) ^ (y >> 10)
      schedule[index] = schedule[index - 16] +
        sigma0 +
        schedule[index - 7] +
        sigma1
    }
    let mut a = state[0]
    let mut b = state[1]
    let mut c = state[2]
    let mut d = state[3]
    let mut e = state[4]
    let mut f = state[5]
    let mut g = state[6]
    let mut h = state[7]
    for index in 0..<64 {
      let sum1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
      let choice = (e & f) ^ (e.lnot() & g)
      let temp1 = h + sum1 + choice + sha256_constants[index] + schedule[index]
      let sum0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
      let majority = (a & b) ^ (a & c) ^ (b & c)
      let temp2 = sum0 + majority
      h = g
      g = f
      f = e
      e = d + temp1
      d = c
      c = b
      b = a
      a = temp1 + temp2
    }
    state[0] = state[0] + a
    state[1] = state[1] + b
    state[2] = state[2] + c
    state[3] = state[3] + d
    state[4] = state[4] + e
    state[5] = state[5] + f
    state[6] = state[6] + g
    state[7] = state[7] + h
    offset += 64
  }
  state
}

///|
/// Compute a lowercase SHA-256 digest of arbitrary bytes.
pub fn sha256_bytes(input : Bytes) -> String {
  let output = StringBuilder(size_hint=64)
  for word in sha256_words(input) {
    output.write_string((word >> 24).to_byte().to_hex())
    output.write_string((word >> 16).to_byte().to_hex())
    output.write_string((word >> 8).to_byte().to_hex())
    output.write_string(word.to_byte().to_hex())
  }
  output.to_string()
}

///|
/// Compute a lowercase SHA-256 digest of the UTF-8 bytes of `input`.
pub fn sha256_text(input : String) -> String {
  sha256_bytes(@utf8.encode(input))
}
