import os

proc evade(userArgs: pointer): string =
    if paramCount() < 1:
        quit(-1)

    return paramStr(1)

export evade
