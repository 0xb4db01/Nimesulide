#import winim/lean

proc xorro(data: var openArray[byte]; key: string): seq[char] =
    for i in 0 ..< data.len:
        for j in 0 ..< key.len:
            data[i] = data[i] xor uint8(ord(key[j]))

export xorro
