# Tools

## genXORedLoader

This is the only tool available by default with Nimesulied at the moment.

It will generate a nim loader that you can then compile provided you have:

- A config file (see config/README.md).
- A PI shellcode saved in a file.
- A XOR key.

Run it from Nimesulide's main directory.

```
./tools/genXORedLoader config/default.json
```

Of course, create a config file that suits your needs. The default JSON config file is there as an example.
