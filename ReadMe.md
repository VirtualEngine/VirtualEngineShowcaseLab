The VirtualEngineShowcaseLab composite DSC resources can be used to create the Virtual Engine standardised
Active Directory Showcase environment. This module contains the following DSC resources:

### Included Resources

* vShowcaseLab
 * Creates the Showcase folders, file shares, OUs, users, service accounts and groups.
* vShowcaseLabAccdbOdbc
 * Creates the Showcase HR database ODBC connection. 

### Requirements

There are __dependencies__ on the following DSC resources:

* xSmbShare - https://github.com/PowerShell/xSmbShare
* xActiveDirectory - https://github.com/PowerShell/xActiveDirectory
* PrinterManagement - https://github.com/VirtualEngine/PrinterManagement
* PowerShellAccessControl - https://github.com/rohnedwards/PowerShellAccessControl
* VirtualEngineLab - https://github.com/VirtualEngine/VirtualEngineLab
* VirtualEngineTrainingLab - https://github.com/VirtualEngine/VirtualEngineTrainingLab
