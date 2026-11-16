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
| PSReadLine | Any (required module) |
 
PS.Severance is built as a PowerShell module targeting modern PowerShell editions.
 
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
    -Name Production `
    -ColorCode "#00B894"
```
 
Example with tenant information:
 
```powershell
New-PSSEnvironment `
    -Name Production `
    -ColorCode "#FF5555" `
    -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -Organization "contoso"
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
 
## Manage Environment Variables
 
Each environment stores its variables in `Environment_Variables.json`. Manage them with:
 
```powershell
# Add or update variables (built-in or custom)
Update-PSSEnvVariable -Environment Production -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
Update-PSSEnvVariable -Environment Production -CustomVariableName "ApiUrl" -CustomVariableValue "https://api.contoso.com"
 
# Load the environment's variables into the current session (global scope)
Import-PSSEnvVariable -Environment Production
 
# Remove a variable from the environment
Remove-PSSEnvVariable -Environment Production -VariableName "ApiUrl"
 
# Inspect an environment and its variables
(Get-PSSEnvironment -Environment Production).Variables
```
 
Variables are automatically imported when a severed console or workspace session starts.
 
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
 
PS.Severance can install VS Code, the required extension, and the PowerShell profile entries for you:
 
```powershell
Install-PSSDependency -Part All
```
 
Or install individual parts:
 
```powershell
Install-PSSDependency -Part VSCode, VSCodeExtensions
Install-PSSDependency -Part PowerShellProfile
```
 
---
 
# Public Commands
 
| Command | Alias | Purpose |
|----------|--------|----------|
| `New-PSSEnvironment` | `NPSSEnv` | Create a new severed environment (name, colour, tenant ID, organization, optional custom module versions) |
| `Get-PSSEnvironment` | `GPSSEnv` | List all environments, or one environment, with their paths and variables |
| `Remove-PSSEnvironment` | `RPSSEnv` | Remove an environment folder and all of its data |
| `New-PSSConsole` | `PSSCon` | Open an environment-specific Windows Terminal tab with its colour and title |
| `New-PSSVSCodeWorkSpaceSession` | `PSSVsc` | Open an environment's root folder as a VS Code workspace |
| `Update-PSSEnvVariable` | `UPSSEV` | Add or update an environment's variables (ColorCode, TenantId, Organization, custom variables, custom module usage) |
| `Import-PSSEnvVariable` | `IPSSEV` | Load an environment's variables into the current session's global scope |
| `Remove-PSSEnvVariable` | — | Remove a variable from an environment's configuration |
| `Install-PSSCustomModule` | `IPSSCM` | Install a specific module version into an environment's CustomModules folder |
| `Install-PSSDependency` | — | Install supporting components: VS Code, VS Code extensions, and/or PowerShell profile entries |
| `Invoke-PSSGetStarted` | `PSSGetStarted` | Display the onboarding / getting started guide |
| `Invoke-PSSWelcome` | `PSSWelcome` | Display the PS.Severance welcome message with ASCII art |
| `Invoke-PSSVisual` | `PSSVisual` | Display PS.Severance credits as a visual experience |
| `Uninstall-PSSeverance` | — | Remove PS.Severance and its profile configuration (environments are preserved) |
 
Use `Get-Help <command> -Full` for detailed parameter documentation and examples.
 
 
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

<img width="85" height="85" alt="PSSLogoSmall" src="https://github.com/user-attachments/assets/b7b8d62b-56ca-474d-b896-636dc22f98c0" />

---
 
# About the Project
 
PS.Severance was created by **Teemu "Mokka" Kettunen** to provide an efficient way to manage multiple isolated PowerShell environments while maintaining clarity, safety, and flexibility for modern administrators and consultants.
