<#
.SYNOPSIS
    Move local share, data and permissions to another local drive.

.DESCRIPTION
    Uses robocopy to transfer share data and NTFS permissions to another local drive.
    It then recreates the share and share permissions on this new location.
    A final robocopy is done to transfer any changes files since the start of the operation.

.PARAMETER ShareName
    The name of the Share that you would like to move.

.PARAMETER DestSharePath
    The path where you want the share data to be moved.

.PARAMETER Overwrite
    If the destination share path already exists, perhaps because you have copied data previously
    you can set the Overwrite parameter to $true to continue the operation. Otherwise the process
    will exit.

.EXAMPLE
    # Move share 'TestShare' to 'E:\Shares\TestShare'
    Move-LocalShare("TestShare", "E:\Shares\TestShare")

.EXAMPLE
    # Move share 'TestShare' to 'E:\Shares\TestShare'
    Move-LocalShare -SourceShareName "TestShare" -DestSharePath "E:\Shares\TestShare"

.EXAMPLE
    # Move share 'TestShare' to 'E:\Shares\TestShare' bypassing destination checks
    Move-LocalShare("TestShare", "E:\Shares\TestShare", $true)

.Example
    # Move share 'TestShare' to 'E:\Shares\TestShare' bypassing destination checks
    Move-LocalShare -SourceShareName "TestShare" -DestSharePath "E:\Shares\TestShare" -Overwrite $true
#>
function Move-LocalShare {
    param(
        [parameter( Mandatory = $true )]
        [string]$ShareName,
        
        [parameter( Mandatory = $true )]
        [string]$DestSharePath,

        [bool]$Overwrite
    )

    #
    # Get source share object if it exists
    #
    $source_share = GetShareByName -Name $ShareName
    if ($source_share -eq $null)
    {
        Write-Host "Share name not found or error occurred."
        return
    }

    #
    # Store a copy of the share permissions
    #
    $share_permissions = GetShareSecurity -ShareName $ShareName

    if ($share_permissions -eq $null)
    {
        Write-Host "Failed to get share permissions."
        return
    }

    #
    # Check destination / overwrite
    #
    if (Test-Path $DestSharePath -PathType Container)
    {
        if (!($Overwrite))
        {
            Write-Host "Destination folder exists and overwrite flag not set."
            return
        }
    }

    #
    # Copy files, folders and NTFS permissions
    #
    Mirror -src $source_share.Path -dst $DestSharePath

    #
    # Delete original share
    #
    $result = ($source_share).Delete()

    if ($result.ReturnValue -ne 0)
    {
        Write-Host "Error deleting share. Return value: {$result.ReturnValue}"
        return
    }

    #
    # Create share on new path
    #
    (Get-WmiObject Win32_Share -List).Create($DestSharePath, $ShareName, 0)

    #
    # Apply saved permissions to share
    #
    $result = (Get-WmiObject Win32_Share -Filter "Name='$ShareName'").SetShareInfo($null, $null, $share_permissions)

    if ($result.ReturnValue -ne 0)
    {
        Write-Host "Error setting share security on destination share. Return value: {$result.ReturnValue}"
        return
    }

    #
    # Final mirror in-case of changes.
    #
    Mirror -src $source_share.Path -dst $DestSharePath

    Write-Host "Success!"
}


function GetShareByName([string]$Name)
{
    try
    {
      return Get-WmiObject Win32_Share -Filter "Name='$Name'";
    }
    catch
    {
      return $null
    }
}

function GetShareSecurity([string]$ShareName)
{
    $share_sec = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -Filter "Name='$ShareName'"

    try 
    {
        return $share_sec.GetSecurityDescriptor().Descriptor
    }
    catch
    {
        return $null
    }
}

function Mirror($src, $dst)
{
  Write-Host Moving $src to $dst
  robocopy $src $dst /COPYALL /SECFIX /MIR /DCOPY:DAT /MT:8
}

Export-ModuleMember -Function Move-LocalShare