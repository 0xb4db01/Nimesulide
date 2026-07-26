# Evasion techniques for sandbox & emulation

This section is for functions that allow to evade sandbox or automatic emulated analysis. This is not for techniques such as sleep obfuscation or syscalls, this is just stuff you want to do to avoid security checks that can be done on your loaders as you drop them on disk. Ideally, you are going to load something that can handle those other techniques.

Just to be transparent, I tested this only with Microsoft Defender on Windows 11 home edition. 

So, an evasion module is a function that returns a string which represents the XOR key to decrypt the payload. Nothing more.

Nimesulide ships with 2 evasion techniques:

- cliargs: adds logic to grab they key from cli argument, meaning that your payload will run if you provide the key in argv[1].
- user: grabs the username from ENV and uses it as key.

Since Nimesulide can produce EXE and DLL files, the evasion techniques have been separated because the logic may differ. For example, cliargs for EXE can't be used in DLLs for obvious reasons. *Also, note that for the DLL loader, if you want to use cliargs, will work only with rundll32.exe*.

Generic evasion functions are the ones that can be used in all possible loaders. By default, we only have the `user` one.

Feel free to write your own with cool things such as DNS, smb pipes, HTTPs requests or whatever to grab the XOR decryption key.

*IMPORTANT: At the moment, no evasion technique is implemented for SVC.*

## Techniques implemented

- `cliargs`: key via cli arg
- `user`: key via username in environment variable

## Specifications

To implement an evasion function you can create a nim source file, where you can define and export a function that *must* be as following:

```nim
proc evade(userArgs: pointer): string =
    <your code here>

    return superSecretKey

export evade
```

## Implementation constraints

The evasion function name *must* be `evade` and the argument *must* be `userArgs: pointer`. You should never want to have two evasion functions in the same loader anyways, it makes no sense.

Some evasion techniques, such as user or cliargs in exelegacy don't need `userArgs`, so in the template they are invoked as follows:

```
let key = evade(nil)
```

Keep this in mind if you make your own evasion function, or loader with better code than mine.
