<#
  .Synopsis
    Create a standard object
  .Description
    This is a helper function to create a standard object for each check
  .Example
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function New-PSObjectResponse {
  [CmdletBinding()]
  param (
    [String]$Check,
    [String]$Status,
    [String]$Action
  )
  return [PSCustomObject]@{
    "Check" = $Check;
    "Value" = $Status;
    "Action" = $Action
  }
}