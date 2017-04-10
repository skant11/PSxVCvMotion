#Requires -Version 3 -Modules PSake, Pester, VMware.VimAutomation.Core

Function Invoke-xVCvMotion {

    <#
        .NOTES
        https://github.com/equelin/vmware-powercli-workflows
    #>

    [cmdletbinding(ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory=$False)]
        [switch]$Migrate,

        [Parameter(Mandatory=$False)]
        [ValidateScript({If ($_.FullName) {Test-Path $_.FullName} Else {Test-Path $_}})]
        [string]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.ps1",

        [Parameter(Mandatory=$False)]
        [ValidateScript({If ($_.FullName) {Test-Path $_.FullName} Else {Test-Path $_}})]
        [string]$buildFile = "$(Split-Path -Parent $PSScriptRoot)\PSake\psakeBuild.ps1",

        [Parameter(Mandatory=$False)]
        [ValidateScript({If ($_.FullName) {Test-Path $_.FullName} Else {Test-Path $_}})]
        [string]$Test = "$(Split-Path -Parent $PSScriptRoot)\Tests\"
    )   

    Process {

        # Set $Task variable
        If ($Migrate) {
            $Task = 'All'
        } else {
            $Task = 'Default'
        }

        # Get full path for config file
        $Config = (get-item $Config).VersionInfo.FileName

        # Invoke PSake
        Invoke-psake -buildFile $buildFile -taskList $Task -parameters @{"Config"=$Config;"Test"=$Test} -Verbose:$VerbosePreference

    }
}
