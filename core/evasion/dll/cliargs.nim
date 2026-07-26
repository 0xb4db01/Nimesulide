import std/strutils

proc evade(userArgs: pointer): string =
    let cmdLine: cstring = cast[cstring](userArgs)
    let args = $cmdLine
    let parts = args.splitWhitespace()

    return parts[0]

export evade
