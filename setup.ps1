$MyPath = "$ENV:PATH;c:\FASM"
$FasmExe = "C:\FASM\FASM.EXE"
$NUll = Set-EnvironmentVariable -Name "PATH" -Value "$MyPath" -Scope Session 
$NUll = Set-EnvironmentVariable -Name "INCLUDE" -Value "C:\FASM\INCLUDE" -Scope Session  

$SourceDirectory = "$PSScriptRoot\src"
$BinaryDirectory = "$PSScriptRoot\bin"
$AsmFiles = (gci "$SourceDirectory" -File -Filter "*.asm").Fullname
$Null = New-Item "$BinaryDirectory" -ItemType Directory -Force -ErrorAction Ignore
Push-Location "$BinaryDirectory"

ForEach($file in $AsmFiles){
    &"$FasmExe" "$file" *> "$ENV:TEMP\out.txt"
    $Basename = (Get-Item "$file").Basename
    $Name = (Get-Item "$file").Name
    $outfile = "{0}\{1}.exe" -f "$SourceDirectory", "$Basename"
    $binfile = "{0}\{1}.exe" -f "$BinaryDirectory", "$Basename"
    if(Test-Path $binfile){
        Move-Item $binfile $BinaryDirectory -ErrorAction Ignore
        Write-Host "Compiled $Name => " -n 
        Write-Host "$binfile" -f DarkGreen
    }else{
        Write-Host "Compiled $Name => " -n 
        Write-Host "FAILED" -f DarkRed
    }
}

Pop-Location