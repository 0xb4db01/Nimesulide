# Nimesulide

This is a tiny framework I made to create Windows executable shellcode loaders that evade static and emulated analysis which could possibly get automatically triggered when dropping stuff on disk.

I wrote this for penetration testing and red teaming exercises. If you use this stuff for illegal purposes you're sad AF and I hate you. But who cares, this will probably get signaturized quickly and good luck tweaking it to avoid signatures (hint: it's probably not even worth the effort).

Don't expect too much, it's the bare bones stuff. You can always improve this.

## Installation

Prerequisites:

- nim compiler installed
- mingw compiler to cross compile for Windows

I don't even remember how I installed these, so you're on your own here.

Once you have the prerequisites all done and working, clone this repo and then run build.sh. Yes, probably there are better ways to "make" in Nim, but I don't know them and, honestly, this isn't the kind of project that deserves this type of elegance.

## Structure

### config

This directory is for JSON configuration files. Refer to the README in config for more information.

### core

This is the core source directory. It has all the nim code for:

- Payload encryption
- Sandbox/emulation evasion
- Loader functions
- Loader templates
- Utility modules
- Generated loader directory

#### Encryption

Payload encryption is limited to XOR at the moment.

#### Sandbox & emulation evasion

Evasion is documented in core/evasion/README.md

#### Loader functions

Functions that actually load and execute shellcode. See more in `core/load_func/README.md`.

#### Loader templates

There are two type of loaders. 

Legacy, which is the most basic loader possible:

- VirtualAlloc READ/WRITE
- Decrypt payload
- VirtualProtect `PAGE_EXECUTE_READ`
- CreateThread
- WaitForSingleObject
- ...

And Direct Syscall which does the same but levarages direct syscalls.

# Usage

Please use it from Nimesulide's root directory. You should `ls -l` and see this:

```
.
..
build.sh
config
core
loaders
README.md
tools
```

The main reason is that imports and whatever is (or will be) placed in the template's code must be consistent with paths for Nimesulide's modules. Creating ways that retrieve absolute paths or virtual environements that are self consistent is weird and adds complexity. You have brains and opposable thumbs, be sapiens my friend.

The only available tool at the moment is genXORedLoader.

## genXORedLoader

This tool will generate a nim loader that you can then compile provided you have:

- All prerequisites installed and working.
- A config file (see config/README.md).
- A PI shellcode saved in a file (such as: msfvenom -p windows/x64/messagebox TEXT="Hello, h4x0r" -f raw -o msgbox.bin).
- A XOR key.

### EXE

Run from Nimesulide's main directory the following:

```
./tools/genXORedLoader config/exelegacy.json
```

### DLL

Run from Nimesulide's main directory the following:

```
./tools/genXORedLoader config/dllegacy.json
```

### SVC

Run from Nimesulide's main directory the following:

```
./tools/genXORedLoader config/svclegacy.json
```

Of course, the config files here are the ones that ship with Nimesulide and they serve as example. Make your own or modify them to your needs.

Also, these examples are for legacy loader. Use the examples for direct syscalls if you wish to go that path.

## Testing & state of the art

I tested this on Windows 11 Home with default MS Defender. With meterpreter both staged and not staged, the EXE sometimes gets caught right after establishing connection.

Metasploit's `impersonate_ssl` modules seemed to have done some fix but, again, it got caught a couple of times. I didn't debug so I don't know exactly what's happening. It's just arbitrary.

You can try adding some `sleep` before decrypting in the `loadPayload` function, it did the trick for me but then, plain EXE loader as is got back to work without any tweaks. It's weird, I don't really care ATM.

DLL and SVC went pretty straight forward till now.
