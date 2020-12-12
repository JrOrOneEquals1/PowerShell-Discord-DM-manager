# PowerShell Discord DM Manager
## Description

This PowerShell script will use the Selenium Web Driver with the Chrome browser to automatically respond to Direct Messages (DMs) that you receive in [Discord](https://discord.com) when keywords that you specify are received. It will only respond with the keyword triggered message once per Discord user. This has only been tested on Windows.

## Installation
First, you will need to install [Selenium for PowerShell](https://github.com/adamdriscoll/selenium-powershell). This can be done from a PowerShell command prompt with the following command.

```powershell
Install-Module Selenium -Scope CurrentUser
```

Next, download the webdriver version that matches your Chrome browser version from http://chromedriver.chromium.org/downloads and replace the version of `chromedriver.exe` in your `Documents\WindowsPowerShell\Modules\Selenium\3.0.1\assemblies` directory.

Download `main.ps1` from this repository and change your configuration settings at the top of the file before running it.

## Setup

You must implement a PowerShell function called `Get-BotMessage` that accepts two strings, the Discord DM user ID and username. An example function is given below. Of course your function could be generating some dynamic user specific content, such as a different IP, each time it is called.

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

Before starting the PowerShell script, remember to configure your settings for keywords, and other settings at the top of the main.ps1 file.
You can provide multiple keywords but they must match the whole message to be responded. For example, if one of your keywords is `Pizza`, this tool wil not reply to a message of `I like Pizza`. The keyword comparison is case-insensitive, if the keyword is `Pizza`, it will respond to a message of `pIzZA`.

Start the PowerShell Script as follows:

```powershell
./main.ps1
```

A Chrome web browser will load to the Discord login page. Complete the login manually using the browser then leave this browser undisturbed, preferably minimized so that you don't interact with it.

To avoid issues, don't interact with this browser while it is being controlled by Selenium. Instead, use or start another instance of the Chrome browser to login to discord and check and respond to messages as you would normally while the script is running. Just don't do this from the Chrome browser being controlled by Selenium.

## Reset

The `WorkingDirectory/sentFile.txt` contains the Discord user IDs for which an automated message has already been sent. You may wish to erase a user ID from this list to force a message to be resent. Erase all the user IDs from this file to reset it so the script will send to anyone who sends the keyword.

If you inadvertantly manually check a DM that contains the keyword before the script checks it, you will need to mark the message with the keyword as unread so that the script will see it.