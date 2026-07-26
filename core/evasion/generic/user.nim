import os

proc evade(userArgs: pointer): string =
    return getEnv("USERNAME")

export evade
