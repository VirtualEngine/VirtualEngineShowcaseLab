configuration vRESONEServiceStorePreparation {
<#
    .SYNOPSIS
        Clears out the RES ONE Service Store Organisation Contexts, Data Connections and Data Source
        before the RES ONE Showcase building blocks are imported.
#>
    param (
        [Parameter(Mandatory)]
        [System.String] $DatabaseName
    )

    $rossPreparationRegistryPath = 'HKLM:\SOFTWARE\Virtual Engine\RESONEServiceStoreDsc';
    $rossPreparationRegistryValue = 'ROSS_Showcase_Preparation';

    Script 'RESONEServiceStorePreparation' {

        GetScript = {

            $getItemPropertyParams = @{
                Path = $using:rossPreparationRegistryPath;
                Name = $using:rossPreparationRegistryValue;
                ErrorAction = 'SilentlyContinue';
            }
            $rossPreparation =  (Get-ItemProperty @getItemPropertyParams).ROSSPreparation;
            return @{
                Result = $rossPreparation -eq 'Yes';
            }
        }

        TestScript = {

            $getItemPropertyParams = @{
                Path = $using:rossPreparationRegistryPath;
                Name = $using:rossPreparationRegistryValue;
                ErrorAction = 'SilentlyContinue';
            }
            $rossPreparation =  (Get-ItemProperty @getItemPropertyParams).$using:rossPreparationRegistryValue;
            return ($rossPreparation -eq 'Yes');
        }

        SetScript = {

            $ross = Import-Module -Name 'RESONEServiceStore' -Force -Verbose:$false -PassThru;
            Connect-ROSSSession -DatabaseServer $env:COMPUTERNAME -DatabaseName $using:DatabaseName;

            $organizationContexts = & $ross {
                Get-ROSSOrganization |
                    Remove-ROSSOrganization -Force -PassThru -WarningAction SilentlyContinue |
                        Select -Expand Name;
            }
            if ($organizationContexts) {
                Write-Verbose -Message ("Deleted organizational contexts: '{0}'." -f [System.String]::Join("','", $organizationContexts));
            }

            $dataConnections = & $ross {
                Get-ROSSDataConnection |
                    Remove-ROSSDataConnection -Force -PassThru -WarningAction SilentlyContinue |
                        Select -Expand Name;
            }
            if ($dataConnections) {
                Write-Verbose -Message ("Deleted data connections: '{0}'." -f [System.String]::Join("','", $dataConnections));
            }

            $dataSources = & $ross {
                Get-ROSSDataSource |
                    Remove-ROSSDataSource -Force -PassThru -WarningAction SilentlyContinue |
                        Select -Expand Name;
            }
            if ($dataSources) {
                Write-Verbose -Message ("Deleted data sources: '{0}'." -f [System.String]::Join("','", $dataSources));
            }

            $setItemPropertyParams = @{
                Path = $using:rossPreparationRegistryPath;
                Name = $using:rossPreparationRegistryValue;
                Value = 'Yes';
            }
            Set-ItemProperty @setItemPropertyParams
        }

    } #end script RESONEServiceStorePreparation

} #end configuration vRESONEServiceStorePreparation