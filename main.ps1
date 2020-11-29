# Configuration
$browser = "Chrome" # other options are "Firefox" and "Edge"
$maximized = $false # set to True if you want the browser to start maximized
$keyWord = "z"
$sleepTime = 2 # time in seconds to sleep before checking messages again
$longSleep = 20

$sentFile = "$PSScriptRoot\WorkingDirectory\sentFile.txt"
if (-not (Test-Path $sentFile) ) { $null = New-Item -ItemType File -Path $sentFile -Force }
$notSentFile = "$PSScriptRoot\WorkingDirectory\notSentFile.txt"
if (-not (Test-Path $notSentFile) ) { $null = New-Item -ItemType File -Path $notSentFile -Force }

# $fileName = Read-Host -Prompt "IP File Path"
# $ipList = Get-Content -Path $fileName
# $ips = $ipList.length - 1

if ($null -eq $Driver) {
    $arguments = @()
    if ($maximized) { $arguments += 'start-maximized' }
    if ($browser -eq "edge") {
        $Driver = Start-SeEdge -Arguments $arguments -Quiet
    }
    elseif ($browser -eq "Firefox") {
        $Driver = Start-SeFirefox -Arguments $arguments -Quiet
    }
    else {
        $Driver = Start-SeChrome -Arguments $arguments -Quiet
    }
    Enter-SeUrl "https://www.discord.com/login" -Driver $Driver

    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}


# Got this from an issue, lets you hover over an element
function Set-SeMousePosition {
    [CmdletBinding()]
    param ($Driver, $Element )
    $Action = [OpenQA.Selenium.Interactions.Actions]::new($Driver)
    $Action.MoveToElement($Element).Perform()
}

# This gets a list of all message after the 'new' bar on discord
function getNewMessages($messagesList) {
    $coords = (Find-SeElement -Driver $Driver -classname "unreadPillCap-3_K2q2").Location.Y # The Y-coordinate of the 'new' bar
    $newMessages = @()
    foreach ($message in $messagesList) {
        if (($null -ne $coords) -and ($message.Location.Y -gt $coords)) {
            $newMessages += $message
        }
    }
    return $newMessages
}

while ($true) {
    $newDMLogEntries = @{}
    $notSent = @{}
    Get-Content $notSentFile | ConvertFrom-Csv | foreach { $notSent[$_.Key] = $_.Value }
    $sentIDs = Get-Content $sentFile
    $listWrappers = Find-SeElement -driver $Driver -classname "listItemWrapper-3X98Pc"
    if ($listWrappers.Length -gt 4) {
        $DMs = $listWrappers[1..$($listWrappers.Length - 4)]
    }
    else { $DMs = @() }
    # add this DM user to the list of people to pay attention to
    foreach ($DM in $DMs) {
        $attribute = (Find-SeElement -driver $DM -classname "wrapper-1BJsBx").GetAttribute("href") # This is the 'guildsnav___USERID' part of the menu buttons
        $id = $attribute.split('/')[-1]
        if (($null -eq $notSent ) -or (-not $notSent[$id])) {
            $newDMLogEntries += @{$id = $(Get-Date "1/1/20") }
        }
    }
    # add new user to list of users to monitor if we haven't already sent the message to them
    foreach ($newDMKey in $newDMLogEntries.Keys) {
        if ((-not $notSent.ContainsKey($newDMKey)) -and (-not ($sentIDs -contains $newDMKey))) {
            $notSent += @{ $newDMKey = $newDMLogEntries[$newDMKey] }
        }
    }

    $staticNotSent = $notSent.Clone()
    foreach ($id in $staticNotSent.Keys) {
        # only continue if its been over 2 minutes since this users messages were last read
        if ( ((Get-Date) - (Get-Date $notSent[$id])).TotalSeconds -lt $longSleep ) { Write-Host -Fore Yellow "Skipping $id"; continue }
        Enter-SeUrl "https://discord.com/channels/@me/$id" -Driver $Driver
        $userName = (Find-SeElement -Driver $Driver -classname "username-1A8OIy")[0].GetAttribute("innerText")
        Write-Host -Fore Green "Checking $userName messages $id"
        $messagesList = Find-SeElement -Driver $Driver -classname "contents-2mQqc9" # These are all the messages in the chat
        $notSent[$id] = Get-Date -format "yyyy/MM/dd hh:mm:ss tt"

        $results = getNewMessages $messagesList
        if($results | where-object {$_.text -match "(\n|^)$keyWord`$"}){
                # Send the message
                $chatboxes = Find-SeElement -Driver $Driver -classname "slateTextArea-1Mkdgw" # The messaging input box
                $IP = "1.2.3.4"
                Write-Host -Fore Cyan "Sending IP $IP to $user"
                Add-Content -Path $sentFile -Value $id # Send $id to file so the script knows to ignore new messages from that user
                Send-SeKeys -Element $chatboxes[-1] -Keys "$IP`n" # Send the IP
                #remove this id from notsent
                $notSent.Remove($id)
        }
        foreach ($result in $results) {
            if (-not ($result.text -match "(\n|^)$keyWord`$")) {
                # Mark messages as unread, click the message so the elipsis button shows up
                $result | Invoke-SeClick
                (Find-SeElement -Driver $Driver -classname "button-1ZiXG9")[2] | Invoke-SeClick -Driver $Driver -JavaScriptClick # The three dots that show up on hover
                (Find-SeElement -Driver $Driver -classname "label-22pbtT")[2]  | Invoke-SeClick -Driver $Driver -JavaScriptClick # The 'Mark Unread' button in the three dots menu    
            }
        }
        Enter-SeUrl "https://discord.com/channels/@me" -Driver $Driver

    }
    $notSent.GetEnumerator() | select-object -Property Key, Value | Export-csv -NoTypeInformation $notSentFile

    Write-Host -Fore Cyan "Sleeping for $sleepTime seconds"
    Start-Sleep $sleepTime
    
}