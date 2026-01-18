$ModelName = "Feedthrough"


# Compile DLL.

## `DISABLE_PREFIX` is needed to export the `fmi3...` functions in the compiled DLL.
cl /LD model.c ./fmi/src/*.c /DFMI_VERSION=3 /DDISABLE_PREFIX

## Clean up.
Remove-Item *.obj
Remove-Item *.exp
Remove-Item *.lib


# Create ZIP archive (FMU file).

## Create temp directory for FMU structure.
$tmp = Join-Path $env:TEMP ("fmu_" + [guid]::NewGuid().ToString("N"))
Write-Host "Using temporary FMU build directory: $tmp"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

## Copy files.
Copy-Item -Force ".\modelDescription.xml" $tmp
$binDir = Join-Path $tmp "binaries\x86_64-windows"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Copy-Item -Force ".\model.dll" (Join-Path $binDir "$ModelName.dll")

## Create FMU.
$zipPath = ".\$ModelName.zip"
$fmuPath = ".\$ModelName.fmu"
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
if (Test-Path $fmuPath) { Remove-Item -Force $fmuPath }
Compress-Archive -Path (Join-Path $tmp "*") -DestinationPath $zipPath
Rename-Item -Force -Path $zipPath -NewName (Split-Path -Leaf $fmuPath)

## Clean up.
[System.IO.Directory]::Delete($tmp, $true)
Remove-Item *.dll
