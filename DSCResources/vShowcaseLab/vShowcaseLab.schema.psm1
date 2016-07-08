#requires -Version 5

configuration vShowcaseLab {
    param (
        ## Active Directory credentials (for DFS creation)
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

        ## Default user password to set/enforce
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Password,

        ## IP address used to calculate reverse lookup zone name
        [Parameter(Mandatory)]
        [System.String] $IPAddress,

        ## Folder containing GPO backup files
        [Parameter(Mandatory)]
        [System.String] $GPOBackupPath,

        #  = 'C:\\SharedData\\Departmental Shares\\HR\\HR_Database.accdb'
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HRDatabasePath,

        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',

        ## File server FQDN containing the user's home directories and profile shares
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FileServer = 'controller.lab.local',

        ## DFS root share
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DFSRoot = 'DFS',

        ## User's home drive assignment
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $HomeDrive = 'H:',

        ## User home directory share name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $HomeShare = 'Home$',

        ## User profile directory share name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ProfileShare = 'Profile$',

        ## Name of the mandatory user profile
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MandatoryProfileName = 'Mandatory',

        ## Hostname for itstore.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ITStoreHost = 'controller.lab.local',

        ## Hostname for storefront.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $StorefrontHost = 'xenapp.lab.local',

        ## Hostname for smtp.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $SmtpHost = 'exchange.lab.local',

        ## Directory path containing user thumbnail photos
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ThumbnailPhotoPath
    )

    ## Avoid recursive loading of the VirtualEngineTrainingLab composite resource
    Import-DscResource -Name vTrainingLabPasswordPolicy, vTrainingLabOUs, vTrainingLabUsers, vTrainingLabServiceAccounts, vTrainingLabGroups, vTrainingLabFolders;
    Import-DscResource -Name vTrainingLabDfs, vTrainingLabGPOs, vTrainingLabDns, vTrainingLabPrinters, vTrainingLabUserThumbnails, vShowcaseLabAccdbOdbc;

    $folders = @(
        @{  Path = 'C:\DFSRoots'; }
        @{
            Path = 'C:\DFSRoots\{0}' -f $DFSRoot;
            Share = $DFSRoot;
            FullControl = 'BUILTIN\Administrators';
            ChangeControl = 'Everyone';
            Description = 'Distributed File System Root Share';
            DfsRoot = $true;
        }
        @{  Path = 'C:\SharedData'; }
        @{
            Path = 'C:\SharedData\App-V Content';
            Share = 'Content';
            Description = 'App-V packages';
            DfsPath = 'Content';
        }
        @{  Path = 'C:\SharedData\Company Share';
            Share = 'Company';
            FullControl = 'Everyone';
            ModifyNtfs = 'Users';
            Description = 'Company-wide shared information';
            DfsPath = 'Company';
        }
        @{ Path = 'C:\SharedData\Company Share\Documentation'; }
        @{ Path = 'C:\SharedData\Company Share\Media'; }
        @{ Path = 'C:\SharedData\Company Share\Financial Confidential'; }
        @{ Path = 'C:\SharedData\Company Share\Portraits'; }
        @{ Path = 'C:\SharedData\Departmental Shares'; }
        @{
            Path = 'C:\SharedData\Profiles';
            Share = 'Profile$';
            FullControl = 'Everyone';
            FullControlNtfs = 'Users';
            Description = 'User roaming profiles';
            DfsPath = 'Profiles';
        }
        @{
            Path = 'C:\SharedData\Profiles\TS Profiles';
            Share = 'TSProfile$';
            FullControl = 'Everyone';
            FullControlNtfs = 'Users';
            Description = 'User Terminal Services roaming profiles';
        }
        @{
            Path = 'C:\SharedData\User Home Directories';
            Share = 'Home$';
            FullControl = 'Everyone';
            Description = 'User home folders';
            DfsPath = 'Home Folders';
        }
        @{
            Path = 'C:\SharedData\PST';
            Share = 'PST';
            FullControl = 'Everyone';
            Description = 'Exported Mailboxes';
            DfsPath = 'Mail Archives';
        }
    ) #end folders

    $rootDN = 'DC={0}' -f $DomainName -split '\.' -join ',DC=';

    $activeDirectory = @{
        OUs = @(
            @{ Name = 'Showcase'; Description = 'Showcase group and user resources'; }
                @{ Name = 'Computers'; Path = 'OU=Showcase'; Description = 'Showcase computer accounts'; }
                @{ Name = 'Groups'; Path = 'OU=Showcase'; Description = 'Showcase security and distribution groups'; }
                @{ Name = 'Servers'; Path = 'OU=Showcase'; Description = 'Showcase server accounts'; }
                @{ Name = 'Service Accounts'; Path = 'OU=Showcase'; Description = 'Showcase service accounts'; }
                @{ Name = 'Users'; Path = 'OU=Showcase'; Description = 'Showcase department users'; }
                    @{ Name = 'Disabled Accounts'; Path = 'OU=Users,OU=Showcase'; Description = 'Deprovisioned user accounts'; }
        )

        GPOs = @{
            'Default Lab Policy' = @{ Link = $rootDN; Enabled = $true; }
            'Invoke Workspace Composer' = @{ Link = "OU=Servers,OU=Showcase,$rootDN"; Enabled = $true; }
        }

        Users = @(
            # Executive
            @{  SamAccountName = 'EXECUTIVE10'; GivenName = 'Executive'; Surname = '10';
                Telephone = '01234 567905'; Mobile = '07700 900440'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Chief Executive Officer'; Department = 'Executive'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='108'; }

            # Engineering
            @{  SamAccountName = 'ENGINEERING10'; GivenName = 'Engineering'; Surname = '10';
                Telephone = '01234 567894'; Mobile = '07700 900622'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Director'; Department = 'Engineering'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='33'; }
            @{  SamAccountName = 'ENGINEERING01'; GivenName = 'Engineering'; Surname = '01';
                Telephone = '01234 567900'; Mobile = '07700 900409'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Engineer'; Department = 'Engineering'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'ENGINEERING10'; EmployeeNumber ='47'; }

            # Finance
            @{  SamAccountName = 'FINANCE10'; GivenName = 'Finance'; Surname = '10';
                Telephone = '01234 567891'; Mobile = '07700 900827'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Director'; Department = 'Finance'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='12'; }
            @{  SamAccountName = 'FINANCE01'; GivenName = 'Finance'; Surname = '01';
                Telephone = '01234 567896'; Mobile = '07700 900468'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Credit Controller'; Department = 'Finance'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'FINANCE10'; EmployeeNumber ='8'; }

            # Information Technology
            @{  SamAccountName = 'IT10'; GivenName = 'IT'; Surname = '10';
                Telephone = '01234 567893'; Mobile = '07700 900155'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Director'; Department = 'Information Technology'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='28'; }
            @{  SamAccountName = 'IT01'; GivenName = 'IT'; Surname = '01';
                Telephone = '01234 567898'; Mobile = '07700 900872'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Helpdesk Anaylst'; Department = 'Information Technology'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'IT10'; EmployeeNumber ='10'; }

            # Marketing
            @{  SamAccountName = 'MARKETING10'; GivenName = 'Marketing'; Surname = '10';
                Telephone = '01234 567890'; Mobile = '07700 900738'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Director'; Department = 'Marketing'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='16'; }
            @{  SamAccountName = 'MARKETING01'; GivenName = 'Marketing'; Surname = '01';
                Telephone = '01234 567895'; Mobile = '07700 900009'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Graphic Artist'; Department = 'Marketing'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'MARKETING10'; EmployeeNumber ='7'; }

            # Sales
            @{  SamAccountName = 'SALES10'; GivenName = 'Sales'; Surname = '10';
                Telephone = '01234 567892'; Mobile = '07700 900834'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Director'; Department = 'Sales'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='17'; }
            @{  SamAccountName = 'SALES01'; GivenName = 'Sales'; Surname = '01';
                Telephone = '01234 567897'; Mobile = '07700 900747'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Account Manager'; Department = 'Sales'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'SALES10'; EmployeeNumber ='18'; }

            # HR
            @{  SamAccountName = 'HR10'; GivenName = 'HR'; Surname = '10';
                Telephone = '01234 567906'; Mobile = '07700 900087'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Director'; Department = 'HR'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'EXECUTIVE10'; EmployeeNumber ='45'; }
            @{  SamAccountName = 'HR01'; GivenName = 'HR'; Surname = '01';
                Telephone = '01234 567907'; Mobile = '07700 900249'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'HR Administrator'; Department = 'HR'; Office = 'Head Office'; Company = 'Stark Industries';
                Path = 'OU=Users,OU=Showcase'; ManagedBy = 'HR10'; EmployeeNumber ='46'; }
        )

        ServiceAccounts = @(
            @{  SamAccountName = 'RESAM'; GivenName = 'RES'; Surname = 'Service AM';
                Description = 'RES ONE Automation Service Account'; Path = 'OU=Service Accounts,OU=Showcase'; }
            @{  SamAccountName = 'RESITS'; GivenName = 'RES'; Surname = 'Service ITS';
                Description = 'RES ONE Service Store Service Account'; Path = 'OU=Service Accounts,OU=Showcase'; }
            @{  SamAccountName = 'RESWM'; GivenName = 'RES'; Surname = 'Service WM';
                Description = 'RES ONE Workspace Service Account'; Path = 'OU=Service Accounts,OU=Showcase'; }
        )

        ## Universal group required to mail-enable
        Groups = @(
            @{ Name = 'Engineering'; Path = 'OU=Groups,OU=Showcase'; Description = 'Engineering users'; Scope = 'Universal'; ManagedBy = 'ENGINEERING10'; }
            @{ Name = 'Executive'; Path = 'OU=Groups,OU=Showcase'; Description = 'Executive users'; Scope = 'Universal'; ManagedBy = 'EXECUTIVE10'; }
            @{ Name = 'Finance'; Path = 'OU=Groups,OU=Showcase'; Description = 'Finance users'; Scope = 'Universal'; ManagedBy = 'FINANCE10'; }
            @{ Name = 'Information Technology'; Path = 'OU=Groups,OU=Showcase'; Description = 'IT users'; Scope = 'Universal'; ManagedBy = 'IT10'; }
            @{ Name = 'Marketing'; Path = 'OU=Groups,OU=Showcase'; Description = 'Marketing users'; Scope = 'Universal'; ManagedBy = 'MARKETING10'; }
            @{ Name = 'Sales'; Path = 'OU=Groups,OU=Showcase'; Description = 'Sales users'; Scope = 'Universal'; ManagedBy = 'SALES10'; }
            @{ Name = 'HR'; Path = 'OU=Groups,OU=Showcase'; Description = 'Human Resource users'; Scope = 'Universal'; ManagedBy = 'HR10'; }
            @{ Name = 'RES AM Administrators'; Path = 'OU=Groups,OU=Showcase'; Description = 'RES ONE Automation administation accounts';
                Members = 'Domain Admins','Information Technology'; Scope = 'DomainLocal'; }
            @{ Name = 'RES AM Service Accounts'; Path = 'OU=Groups,OU=Showcase'; Description = 'RES ONE Automation service accounts';
                Members = 'RESAM'; Scope = 'DomainLocal'; }
            @{ Name = 'RES ITS Administrators'; Path = 'OU=Groups,OU=Showcase'; Description = 'RES ONE Service Store administation accounts';
                    Members = 'Domain Admins','Information Technology'; Scope = 'DomainLocal'; }
            @{ Name = 'RES ITS Service Accounts'; Path = 'OU=Groups,OU=Showcase'; Description = 'RES ONE Service Store service accounts';
                    Members = 'RESITS'; Scope = 'DomainLocal'; }
            @{ Name = 'RES WM Administrators'; Path = 'OU=Groups,OU=Showcase'; Description = 'RES ONE Workspace administation accounts';
                    Members = 'Domain Admins','Information Technology'; Scope = 'DomainLocal'; }
            @{ Name = 'RES WM Service Accounts'; Path = 'OU=Groups,OU=Showcase'; Description = 'RES ONE Workspace service accounts';
                    Members = 'Domain Admins','RESWM'; Scope = 'DomainLocal'; }

            ## Add RES AM Service Account to domain admins
            @{ Name = 'Domain Admins'; Path = 'CN=Users'; Members = 'RESAM'; }
        )

    } #end ActiveDirectory

    #region DNS
    vTrainingLabDns 'ReverseLookupAndCNames' {
        IPAddress = $IPAddress;
        DomainName = $DomainName;
        ITStoreHost = $ITStoreHost;
        StorefrontHost = $StorefrontHost;
        SmtpHost = $SmtpHost;
    }
    #endregion DNS

    #region Active Directory
    vTrainingLabPasswordPolicy 'PasswordPolicy' {
        DomainName = $DomainName;
    }

    vTrainingLabOUs 'OUs' {
        OUs = $activeDirectory.OUs;
        DomainName = $DomainName;
    }

    vTrainingLabServiceAccounts 'ServiceAccounts' {
        ServiceAccounts = $activeDirectory.ServiceAccounts;
        Password = $Password;
        DomainName = $DomainName;
    }

    vTrainingLabUsers 'Users' {
        Users = $activeDirectory.Users;
        Password = $Password;
        DomainName = $DomainName;
        FileServer = $FileServer;
        HomeDrive = $HomeDrive;
        ProfileShare = $ProfileShare;
        MandatoryProfileName = $MandatoryProfileName;
    }

    vTrainingLabGroups 'Groups' {
        Groups = $activeDirectory.Groups;
        Users = $activeDirectory.Users;
        DomainName = $DomainName;
    }
    #endregion Active Directory

    #region Group Policy
    vTrainingLabGPOs 'GPOs' {
        GPOBackupPath = $GPOBackupPath;
        GroupPolicyObjects = $activeDirectory.GPOs;
        DependsOn = '[vTrainingLabOUs]OUs';
    }
    #endregion Group Policy

    $departments = $activeDirectory.Users | % { $_.Department } | Select -Unique;

    vTrainingLabFolders 'Folders' {
        Folders = $folders;
        Users = $activeDirectory.Users;
        Departments = $departments;
    }

    vTrainingLabDfs 'Dfs' {
        Folders = $folders;
        Credential = $Credential;
        DFSRoot = $DFSRoot;
        DomainName = $DomainName;
        FileServer = $FileServer;
        Departments = $departments;
    }

    vTrainingLabPrinters 'Printers' {
        Departments = $departments;
    }

    if ($PSBoundParameters.ContainsKey('ThumbnailPhotoPath')) {
        vTrainingLabUserThumbnails 'UserThumbnailPhotos' {
            Users = $activeDirectory.Users;
            ThumbnailPhotoPath = $ThumbnailPhotoPath;
            DomainName = $DomainName;
            Extension = 'jpg';
        }
    }

    vShowcaseLabAccdbOdbc 'HRDatabaseOdbc' {
        AccdbDatabasePath = $HRDatabasePath;
    }

} #end configuration vShowcaseLab
