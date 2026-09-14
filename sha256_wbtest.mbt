///|
test "SHA-256 empty standard vector" {
  assert_eq(
    sha256_text(""),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
}

///|
test "SHA-256 abc standard vector" {
  assert_eq(
    sha256_text("abc"),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
}

///|
test "SHA-256 multi-block standard vector" {
  assert_eq(
    sha256_text("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
    "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1",
  )
}

///|
test "SHA-256 Unicode hashes UTF-8 bytes" {
  assert_eq(
    sha256_text("机器人"),
    "a4d14414860b025b08648767a1c05440bb1784bbfe3070851ee39ea621eb9f2d",
  )
}

///|
test "SHA-256 binary bytes are not text-normalized" {
  let bytes = Bytes::from_array([b'\x00', b'\xff', b'\x0d', b'\x0a'])
  assert_eq(
    sha256_bytes(bytes),
    "e9489f37fb3051e9efa1dc916004d7274e7b63975e3209708947267f2393a9be",
  )
}
