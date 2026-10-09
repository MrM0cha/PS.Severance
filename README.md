<img width="500" height="500" alt="Designer" src="https://github.com/user-attachments/assets/a5e055b5-efcd-43c3-bc49-92decaec68e9" />

# PS.Severance
 
> Create truly isolated PowerShell environments with separate configuration, command history, variables, console identities, and even module versions.
 
PS.Severance is a PowerShell 7.5+ module designed to help consultants, administrators, developers, and automation engineers work across multiple customers, tenants, projects, or environments without configuration bleed-over. Each environment becomes its own logical workspace with independent settings and context.
 
---
 
# Why PS.Severance?
 
Anyone who regularly works with multiple Microsoft 365 tenants, Azure environments, customer projects, or development stages has likely experienced at least one of these problems:
 
- Running commands against the wrong tenant
- Mixing command history between customers
- Loading the wrong module version
- Losing track of which environment a console belongs to
- Accidentally using production credentials in a development session
 
PS.Severance addresses these challenges by introducing **severed environments**. Each environment maintains its own identity and configuration while remaining easy to launch from PowerShell or VS Code.
 
---
 
# Key Features
 
## Environment Isolation
 
Each environment maintains its own:
 
- Environment variables
- Working directory
- VS Code workspace settings
- Command history
- Console title
- Visual colour identity
- Modules
 
When a severed environment is loaded, PS.Severance automatically switches to the environment location and uses a dedicated command history file.
 
## Visual Identification
 
Each environment receives a unique colour profile stored in VS Code settings.
 
The same colour is used when opening Windows Terminal tabs, helping you immediately identify which environment you are working in. This greatly reduces the risk of administrative mistakes.
 
## Environment-Specific Module Versions
 
Need different versions of the same module?
 
PS.Severance can maintain a dedicated **CustomModules** folder per environment. During environment initialization, these modules can be loaded separately from your global PowerShell installation.
 
## VS Code Integration
 
Launch a dedicated workspace directly into a PS.Severance environment.
 
The environment's root folder becomes the VS Code workspace, allowing customer-specific scripts, documentation, and automation assets to remain isolated.
 
---
 
# Requirements
 
| Requirement | Version |
|------------|----------|
| PowerShell | 7.5 or later |
 
PS.Severance is built as a PowerShell module targeting modern PowerShell editions. 【1-96ad2d】
 
---
 
# Installation
 
Install from PowerShell Gallery:
 
```powershell
Install-Module PS.Severance -Scope CurrentUser
```
 
Import the module:
 
```powershell
Import-Module PS.Severance
```
 
During first use, PS.Severance registers required configuration variables and updates your PowerShell profiles so the module is automatically available in future sessions.
 
---
 
# First-Time Setup
 
Upon first launch, PS.Severance prompts for an environment root folder.
 
Example:
 
```text
C:\Environments
```
 
This becomes the central location where all severed environments are stored.
 
The module automatically configures:
 
- `$ENV:PSSEnvRoot`
- `$ENV:PSSConPrefix`
- `$ENV:PSSWelcomeAscii`
- Automatic module loading from PowerShell profiles
 
These settings are written to both standard PowerShell and VS Code PowerShell profiles.
 
---
 
# Quick Start
 
## Create an Environment
 
```powershell
New-PSSEnvironment `
    -Name Production`
    -ColorCode "#00B894"
```
 
Example with tenant information:
 
```powershell
New-PSSEnvironment `
    -Name Production `
    -ColorCode "#FF5555" `
    -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -Organisation "contoso"
```
 
This creates:
 
```text
<PSSEnvRoot>
└── Production
    ├── .vscode
    │   └── settings.json
    └── Environment_Variables.json
```
 
 
---
 
## Open a Dedicated Console
 
```powershell
New-PSSConsole -Environment Production
```
 
or use the shortcut alias:
 
```powershell
PssCon Production
```
 
A new Windows Terminal tab is opened using the environment colour and title.
 
---
 
## Open VS Code
 
```powershell
New-PSSVSCodeWorkSpaceSession -Environment Production
```
 
Alias:
 
```powershell
PSSVsc Production
```
 
VS Code opens directly to the selected environment workspace.
 
---
 
# Custom Module Version Management
 
One of the most powerful PS.Severance features is environment-specific module versioning.
 
Create an environment with custom module support:
 
```powershell
New-PSSEnvironment `
    -Name LegacyProject `
    -ColorCode "#FFB300" `
    -UseCustomModuleVersions
```
 
Install a specific module version:
 
```powershell
Install-PSSCustomModule `
    -Environment LegacyProject `
    -Name Microsoft.Graph `
    -RequiredVersion 2.28.0
```
 
The module is downloaded into the environment's dedicated CustomModules folder rather than relying on globally installed versions.
 
---
 
# Recommended VS Code Extensions
 
Required for the best experience:
 
- PowerShell (Microsoft)
- Color Them Top Bars (Jeff Mathew)
 
Other approved extensions:
 
- Better Comments
- Colored Regions
- Show Unsaved Changes
- Edit CSV
- Rainbow CSV
- vscode-pdf
 
---
 
# Built-In Commands
 
| Command | Purpose |
|----------|----------|
| New-PSSEnvironment | Create a new severed environment |
| New-PSSConsole | Open an environment-specific PowerShell console |
| New-PSSVSCodeWorkSpaceSession | Open an environment workspace in VS Code |
| Install-PSSCustomModule | Install environment-specific module versions |
| Invoke-PSSGetStarted | Display onboarding guide |
| Invoke-PSSCredits | Display PS.Severance credits experience |
| Uninstall-PSSeverance | Remove PS.Severance and profile configuration |
 
 
---
 
# Aliases
 
| Alias | Command |
|---------|---------|
| PssCon | New-PSSConsole |
| PssVsc | New-PSSVSCodeWorkSpaceSession |
| GPSSEV | Get-PSSEnvVariables |
| UPSSEV | Update-PSSEnvVariables |
| NPSSEV | New-PSSEnvVariables |
| PSSWelcome | Invoke-PssWelcome |
 
 
---
 
# Getting Started Guide
 
At any time you can re-open the built-in onboarding guide:
 
```powershell
Invoke-PSSGetStarted
```
 
The guide provides recommendations for:
 
1. Creating environments
2. Managing environment variables
3. Installing environment-specific modules
4. Opening dedicated consoles
5. Opening dedicated VS Code workspaces
 
 
---
 
# Uninstall
 
To remove the module:
 
```powershell
Uninstall-PSSeverance
```
 
The uninstall process:
 
- Removes installed PS.Severance module instances
- Cleans PowerShell profile entries
- Preserves all environment folders
 
Your environments remain intact and can be manually removed if desired.
 
---
 
# Typical Use Cases
 
### Microsoft 365 Consulting
 
Maintain separate environments for:
 
- Customer A
- Customer B
- Internal tenant
- Demo tenant
 
Each with distinct variables, contexts, and tooling.
 
### Development
 
Separate:
 
- Development
- Test
- Staging
- Production
 
while maintaining clear visual indicators.
 
### PowerShell Module Testing
 
Load different module versions simultaneously without affecting your global PowerShell installation.
 
### Multi-Tenant Administration
 
Reduce the risk of running commands against the wrong tenant by giving every environment a unique workspace and console identity.
 
---
 
# About the Project
 
PS.Severance was created by **Teemu "Mokka" Kettunen** to provide an efficient way to manage multiple isolated PowerShell environments while maintaining clarity, safety, and flexibility for modern administrators and consultants.
