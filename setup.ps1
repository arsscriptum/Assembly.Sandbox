$MyPath = "$ENV:PATH;c:\FASM"
$FasmExe = "C:\FASM\FASM.EXE"
$NUll = Set-EnvironmentVariable -Name "PATH" -Value "$MyPath" -Scope Session 
$NUll = Set-EnvironmentVariable -Name "INCLUDE" -Value "C:\FASM\INCLUDE" -Scope Session  
$TempDirectory = "$PSScriptRoot\tmp"
$SourceDirectory = "$PSScriptRoot\src"
$BinaryDirectory = "$PSScriptRoot\bin"
$AsmFiles = (gci "$SourceDirectory" -File -Filter "*.asm").Fullname
$Null = New-Item "$TempDirectory" -ItemType Directory -Force -ErrorAction Ignore
$Null = New-Item "$BinaryDirectory" -ItemType Directory -Force -ErrorAction Ignore
Push-Location "$BinaryDirectory"

ForEach($file in $AsmFiles){
    Write-Host "Compiling $file... " -n 
    
    $Basename = (Get-Item "$file").Basename
    $Name = (Get-Item "$file").Name
    $tmpfile = "{0}\{1}.tmp" -f "$TempDirectory", "$Basename"
    &"$FasmExe" "$file" *> "$tmpfile"
    $outfile = "{0}\{1}.exe" -f "$SourceDirectory", "$Basename"
    $binfile = "{0}\{1}.exe" -f "$BinaryDirectory", "$Basename"
    if(Test-Path $outfile){
        Move-Item $outfile $binfile -Force -ErrorAction Ignore
        Write-Host "SUCCESS!" -f DarkGreen
    }else{
        Write-Host "FAILED" -f DarkRed
        $ErrString = Get-Content "$tmpfile" -Raw
        Write-Host "`n=== Errors ===`n$ErrString`n===========" -f DarkGray
    }
}

Pop-Location