# Configuration files

This section is for the configuration files needed to generate loaders with Nimesulide.

## Overview for loader generation

genXORedLoader expects a JSON config file as argument. This file contain all the information needed to produce a loader:

- `type`: the type of loader (EXE, DLL, SVC)
- `loader_template`: the template you want to use
- `evade_import`: nimesulide's evasion nim module
- `binfile`: the shellcode binary file
- `xor_key`: the XOR encryption key
- `outfile`: the nim code for the loader

genXORedLoader will print the nim compile command for the loader.

```JSON
{
    "type": "EXE",
    "loader_template": "core/loaders/exe/exelegacy.nim",
    "evade_import": "../core/evasion/exe/cliargs",
    "binfile": "/path/to/payload.bin",
    "xor_key": "s3cr3t",
    "outfile": "loaders/legacy.nim"
}
```

## Templates

A template is basically a single nim code file with placeholders that will be replaced with actual code by genXORedLoader.

For example, `evade_import` is going to be the nim evasion module. In the example, it's cliargs. 

You *should* run genXORedLoader from nimesulide's directory and use `../core/evasion/<exe|dll>/cliargs` because the output file will be stored in `./loaders` directory. You'll get compile errors if you don't specify `../`.

## Evasion

Evasion is solely for emulation and sandbox analysis that may be triggered when dropping on disk, *not* for behaviour analysis. If you run some shit that triggers memory scans as soon as it runs it's your problem.

More on core/evasion/README.md

## Payloads

Payloads can be whatever you want, provided that they are *pi shellcodes*. Nimesulide, at the moment, doesn't support loaders for executable files. Maybe one day.

## XOR key

At the moment only XOR encryption is supported. Maybe one day I'll add AES or whatever. Hopefully the logic will stay the same, a key is all you need to encrypt and decrypt the payload.

## Output file

Output file is a nim program that you will compile. For convenience, a command line for compiling will be print by genXORedLoader. It's generally what you want: x64 architecture, no debug symbols, stripped. Feel free to change it to your needs.
