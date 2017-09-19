param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
    if ($elevated)
    {
    # could not elevate, quit
    exit
    } else {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile  -executionpolicy bypass -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
exit
}
$error.clear()
try{
    cd "C:\Program Files\NVIDIA Corporation\NVSMI\"
    [int]$numGPU = 0
    $data = (./nvidia-smi -q -d SUPPORTED_CLOCKS)
    [regex]$regex = "Supported Clocks\s+Memory\ +:\ +(?<mem>\d+)+ MHz\s+Graphics\ +:\ (?<core>\d+)\ MHz"
    $regex.Matches($data)| %{ ./nvidia-smi -ac $_.Groups['mem'].value,$_.Groups['core'].value -i ($numGPU++)    }
}
catch{ "Error Occured" }
if(!$error){
Start-Sleep -s 2
exit
}

