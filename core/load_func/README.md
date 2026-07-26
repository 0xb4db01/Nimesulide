# Load functions

This section is for function that actually load in memory the payload and execute it. At the moment, there is only one legacy function that does the most basic (and monitored) technique:

- Allocate memory
- Decrypt payload
- Copy memory for the thread
- Make memory executable
- Create thread
- Wait forever

We keep the decryption task here because we want to do it at the very last, to avoid memory scans as much as possible. Obviously, with advanced EDRs and similar this is far from being OPSEC safe, but it's a start.

You'll probably need to write your own, or tweak this one adding sleeps or suspended threads for dumber behavioral analysis.

## Implementation

Again, there are rules. The loader function *must* be called loadPayload and the parameters *must* be:

- payload: pointer
- payload_len: int
- key: string

Note that the payload len will be casted to `SIZE_T`. Keep this in mind when implementing new loader functions. The idea is to keep things as simple as possible in loader templates and do the heavy lifting in the internals.

Also, pointers in Nim are weird if you're like me, with a basic hacky knowledge of the language. Passing it to functions (such as xorro in the legacy case) that expect an `openArray` or an `array` requires some heavy casting, such as:

```nim
cast[ptr UncheckedArray[byte]](payload)
```

## Considerations

The legacy loader function shamelessly uses VirtualAlloc, VirtualProtect and so. These are quite monitored for behavior. I am very tempted to add NO! Not now, sorry.
