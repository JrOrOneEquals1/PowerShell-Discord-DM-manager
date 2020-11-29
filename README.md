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

## Usage

Before starting the PowerShell script, remember to configure your settings for keywords and responses at the top of the file.

Start the PowerShell Script as follows:

```powershell
./main.ps1
```

A web browser will load to the Discord login page and the script will pause. Complete the login manually using the browser and then return to the script and press any key to continue.