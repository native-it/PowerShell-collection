﻿function Get-bdcMicrosoftTeamsReporting
{
   <#
         .SYNOPSIS
         Get a Report for all Microsoft Teams Teams

         .DESCRIPTION
         Get a Report for all Microsoft Teams Teams

         .PARAMETER Connect
         Executes Connect-MicrosoftTeams for you

         .PARAMETER Disconnect
         Executes Disconnect-MicrosoftTeams for you as soon as the report is generated

         .PARAMETER GiphyDetails
         Include Giphy Details in the report

         .PARAMETER MemesDetails
         Include Memes Details in the report

         .PARAMETER GuestDetails
         Include Guest Details in the report

         .PARAMETER Detailed
         Report some more Details about the Teams.

         .PARAMETER AllDetails
         All of the Details are reported, might be a bit verbose for some.

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting

         Get a Report for all Microsoft Teams Teams

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting | Where-Object -FilterScript {
         $_.owners -eq 0
         } | Select-Object -ExpandProperty DisplayName

         Find all Teams without an owner.

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting | Where-Object -FilterScript {
         $_.owners -eq 1
         } | Select-Object -ExpandProperty DisplayName | ForEach-Object -Process {
         Write-Warning -Message "Looks like $_ is an orphaned objects, it has no owner!" -ErrorAction Continue
         }

         Find all Teams without an owner. Teams without an owner are bad teams...

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting | Where-Object -FilterScript {
         ($_.Members -eq 0) -and ($_.Guests -eq 0)
         } | Select-Object -ExpandProperty DisplayName | ForEach-Object -Process {
         Write-Warning -Message "Looks like $_ has no members and guests!" -ErrorAction Continue
         }

         Find Teams without members and guests, empty teams are boring and, more or less, useless

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting | Where-Object -FilterScript {
         ($_.Archived -eq $true) -and ($_.ShowInTeamsSearchAndSuggestions -eq $true)
         } | Select-Object -ExpandProperty DisplayName | ForEach-Object -Process {
         Write-Warning -Message "Looks like $_ is archived but searchable!" -ErrorAction Continue
         }

         Find archived Teams that are still searchable, might not be a bad thing...

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -Connect -Disconnect

         Get a Report for all Microsoft Teams Teams, invokes the Connect-MicrosoftTeams and Diconnect-MicrosoftTeams for you

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -AllDetails

         Get a Report for all Microsoft Teams Teams, with all the details (very verbose)

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -GiphyDetails

         Get a Report for all Microsoft Teams Teams, and include Giphy Details

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -MemesDetails

         Get a Report for all Microsoft Teams Teams, and include Memes Details

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -GiphyDetails -MemesDetails

         Get a Report for all Microsoft Teams Teams, and include Giphy and Memes Details

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -GuestDetails

         Get a Report for all Microsoft Teams Teams, and include Guest Details

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -Detailed

         Get a Report for all Microsoft Teams Teams, with more details then the regular report

         .EXAMPLE
         PS C:\> Get-bdcMicrosoftTeamsReporting -Detailed -GuestDetails

         Get a Report for all Microsoft Teams Teams, with more details then the regular report and Guest Details

         .NOTES
         Reworked function to deliver everything we need to have for our Office 365 reporting service.
         See the examples above and you will get an idea what you can do with filtering :-)

         .LINK
         https://www.powershellgallery.com/packages/MicrosoftTeams/1.0.3

         .LINK
         https://github.com/MicrosoftDocs/office-docs-powershell/tree/master/teams

         .LINK
         Get-Team

         .LINK
         Get-TeamUser

         .LINK
         Get-TeamChannel

         .LINK
         Connect-MicrosoftTeams

         .LINK
         Disconnect-MicrosoftTeams

         .LINK
         https://aka.ms/InstallModule

         .LINK
         https://github.com/tomarbuthnot/Microsoft-Teams-PowerShell

         .LINK
         https://opensource.org/licenses/BSD-3-Clause
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('DoConnect')]
      [switch]
      $Connect,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('DoDisconnect')]
      [switch]
      $Disconnect,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('IncludeGiphyDetails', 'Giphy')]
      [switch]
      $GiphyDetails,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('IncludeMemesDetails', 'Memes')]
      [switch]
      $MemesDetails,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('IncludeGuestDetails', 'Guest')]
      [switch]
      $GuestDetails,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('DetailedReport')]
      [switch]
      $Detailed,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('VerboseReport')]
      [switch]
      $AllDetails
   )

   begin
   {
      #region Connect
      if ($Connect)
      {
         # Logon
         $null = (Connect-MicrosoftTeams)
      }
      #endregion Connect

      # Crete an empty Report variable
      $MicrosoftTeamsReport = @()
   }

   process
   {
      # Get all Microsoft Teams Teams and loop over them
      try
      {
         Get-Team -ErrorAction Stop | ForEach-Object -Process {
            try
            {
               Write-Verbose -Message ('Generate the Report for the Microsoft Teams Team {0}' -f $_.DisplayName)

               # Cleanup
               $TeamUserDetails = $null

               # Get the User information for the Microsoft Teams Team and save it for reuse
               $TeamUserDetails = $null
               $TeamUserDetails = (Get-TeamUser -GroupId $_.GroupID -ErrorAction Stop)

               # Get the Channel information for the Microsoft Teams Team
               $TeamChannelDetails = $null
               $TeamChannelDetails = ((Get-TeamChannel -GroupId $_.GroupID -ErrorAction Stop).count)

               # Put all details into an object
               $SingleTeamReport = (New-Object -TypeName PSobject)

               #region FillSingleTeamReport
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $_.DisplayName
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Description' -Value $_.Description
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Visibility' -Value $_.Visibility

               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Archived' -Value $_.Archived
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'ShowInTeamsSearchAndSuggestions' -Value $_.ShowInTeamsSearchAndSuggestions
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Channels' -Value $TeamChannelDetails
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Owners' -Value (($TeamUserDetails | Where-Object -FilterScript {
                        $_.Role -like 'owner'
                     }).count)
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Members' -Value (($TeamUserDetails | Where-Object -FilterScript {
                        $_.Role -like 'member'
                     }).count)
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Guests' -Value (($TeamUserDetails | Where-Object -FilterScript {
                        $_.Role -like 'guest'
                     }).count)

               #region GiphyDetails
               if ($GiphyDetails -or $AllDetails)
               {
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowGiphy' -Value $_.AllowGiphy
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'GiphyContentRating' -Value $_.GiphyContentRating
               }
               #endregion GiphyDetails

               #region MemesDetails
               if ($MemesDetails -or $AllDetails)
               {
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowStickersAndMemes' -Value $_.AllowStickersAndMemes
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowCustomMemes' -Value $_.AllowCustomMemes
               }
               #endregion MemesDetails

               #region GuestDetails
               if ($GuestDetails -or $AllDetails)
               {
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowGuestCreateUpdateChannels' -Value $_.AllowGuestCreateUpdateChannels
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowGuestDeleteChannels' -Value $_.AllowGuestDeleteChannels
               }
               #endregion GuestDetails

               #region DetailedReport
               if ($Detailed -or $AllDetails)
               {
                  # Based on the idea of Tom Arbuthnot (https://github.com/tomarbuthnot/Microsoft-Teams-PowerShell)
                  $DescriptionWordCount = (($_.Description | Out-String | Measure-Object -Word).words)
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'DescriptionWordCount' -Value $DescriptionWordCount

                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'DescriptionScore' -Value $(if ($DescriptionWordCount -eq 0)
                     {
                        'Terrible'
                     }
                     elseif ($DescriptionWordCount -le 2)
                     {
                        'Poor'
                     }
                     elseif ($DescriptionWordCount -le 5)
                     {
                        'OK'
                     }
                     elseif ($DescriptionWordCount -ge 6)
                     {
                        'Good'
                     }
                     else
                     {
                        'Unknown'
                     }
                  )

                  # As requested by Peter Duda
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'Classification' -Value $(if ($_.Classification)
                     {
                        $_.Classification
                     }
                     else
                     {
                        'None'
                     }
                  )

                  # New since 2020/01
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'MailNickName' -Value $(if ($_.MailNickName)
                     {
                        $_.MailNickName
                     }
                     else
                     {
                        'None'
                     }
                  )

                  # Verbose reporting
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowCreateUpdateChannels' -Value $_.AllowCreateUpdateChannels
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowDeleteChannels' -Value $_.AllowDeleteChannels
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowAddRemoveApps' -Value $_.AllowAddRemoveApps
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowCreateUpdateRemoveTabs' -Value $_.AllowCreateUpdateRemoveTabs
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowCreateUpdateRemoveConnectors' -Value $_.AllowCreateUpdateRemoveConnectors
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowUserEditMessages' -Value $_.AllowUserEditMessages
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowUserDeleteMessages' -Value $_.AllowUserDeleteMessages
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowOwnerDeleteMessages' -Value $_.AllowOwnerDeleteMessages
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowTeamMentions' -Value $_.AllowTeamMentions
                  $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'AllowChannelMentions' -Value $_.AllowChannelMentions
               }
               #endregion DetailedReport

               #region FinalValue
               $SingleTeamReport | Add-Member -MemberType NoteProperty -Name 'GroupId' -Value $_.GroupId
               #endregion FinalValue
               #endregion FillSingleTeamReport

               # Append to the Report
               $MicrosoftTeamsReport += $SingleTeamReport
            }
            catch
            {
               #region WarningHandler
               # get error record
               [Management.Automation.ErrorRecord]$e = $_

               # retrieve information about runtime error
               $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }

               # output information. Post-process collected info, and log info (optional)
               $info | Out-String | Write-Verbose

               $paramWriteWarning = @{
                  Message       = $e.Exception.Message
                  ErrorAction   = 'Continue'
                  WarningAction = 'Continue'
               }
               Write-Warning @paramWriteWarning
               #region WarningHandler
            }
         }
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         $paramWriteError = @{
            Message      = $e.Exception.Message
            ErrorAction  = 'Stop'
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError

         # Just in case
         Exit 1
         #region ErrorHandler
      }
   }

   end
   {
      #region Disconnect
      if ($Disconnect)
      {
         # Logoff
         $null = (Disconnect-MicrosoftTeams -Confirm:$false)
      }
      #endregion Disconnect

      #region ShowReport
      # Dump the Report
      $MicrosoftTeamsReport
      #endregion ShowReport
   }
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
