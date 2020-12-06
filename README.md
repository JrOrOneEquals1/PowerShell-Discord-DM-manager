# PowerShell Discord DM Manager
## Description

This PowerShell script will use the Selenium Web Driver to automatically respond to Direct Messages (DMs) that you receive in [Discord](https://discord.com) when keywords that you specify are received. This has only been tested on Windows.

## Installation
First, you will need to install Selenium for PowerShell from [here](https://github.com/adamdriscoll/selenium-powershell). This can be done from a PowerShell command prompt with the following command.

```powershell
Install-Module Selenium -Scope CurrentUser
```

Next, download the latest version of the web driver from http://chromedriver.chromium.org/downloads and replace the version of `chromedriver.exe` in your `Documents\WindowsPowerShell\Modules\Selenium\3.0.1\assemblies` directory.

Download `main.ps1` from this repository and change your configuration settings at the top of the file before running it.

## Setup

You must implement a PowerShell function called `Get-BotMessage` that accepts two strings, the Discord DM user ID and username. An example function is given below. Of course your function would be generating some dynamic content, such as a different IP, each time it is called.

```powershell
function Get-BotMessage ($discordUserID, $discordUserName) {
    $message = @"
Welcome to the hands-on labs!
You can access the hands-on lab environment by connecting via RDP as follows.
    ip: 1.2.3.4
    username: student
    password: password
Once connected to the remote desktop, open the Chrome browser and click on the 'Labs' bookmark to view the instructions for the hands-on labs.
"@
    return $message
}
```

## Usage

Before starting the PowerShell script, remember to configure your settings for keywords, browser and timing at the top of the file.

Start the PowerShell Script as follows:

```powershell
./main.ps1
```

A web browser will load to the Discord login page and the script will pause. Complete the login manually using the browser and then return to the script and press any key to continue.

To avoid issues, don't interact with this browser while it is being controlled by Selenium. Instead, open a new browser window in which you can use and interact with students while the script is running.

The `WorkingDirectory/sentFile.txt` contains the Discord user IDs for which a bot message has already been sent. You may wish to erase a user ID from this list to force a message to be resent or erase all the entries before starting a new class.

If you inadvertantly manually check a DM that contains the keyword before the script checks it, you will need to mark the message with the keyword as unread so that the script will see it.