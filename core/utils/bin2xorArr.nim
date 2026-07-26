import ../crypto/exor/xorro
import std/[os, strutils]

proc bin2XORArray(filename: string, key: string): string =
    if not fileExists(filename):
        raise newException(IOError, "File not found: " & filename)

    var f = open(filename, fmRead)
    defer: f.close()

    var fileSize:int = getFileSize(f).int

    if fileSize == 0:
        return "[]"

    var data = newSeq[uint8](fileSize)
    let bytesRead = readBytes(f, data, 0, fileSize)

    if bytesRead != fileSize:
        raise newException(IOError, "Failed to read entire file")

    discard xorro(data, key)

    var parts: seq[string] = @[]

    for b in data:
        parts.add("0x" & toHex(b, 2))

    dec fileSize

    result = "var payload: array[0.." & $fileSize & ", byte] = [" & parts.join(", ") & "]"

export bin2XORArray
