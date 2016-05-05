configuration vShowcaseLabAccdbOdbc {
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $AccdbDatabasePath 
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    <#
        Windows Registry Editor Version 5.00

        [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI]

        [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources]
        "SO_Data_Reader"="Microsoft Access Driver (*.mdb, *.accdb)"

        [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader]
        "Driver"="C:\\PROGRA~1\\COMMON~1\\MICROS~1\\OFFICE14\\ACEODBC.DLL"
        "DBQ"=""
        "DriverId"=dword:00000019
        "FIL"="MS Access;"
        "PWD"=""
        "SafeTransactions"=dword:00000000
        "UID"=""

        [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines]

        [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines\Jet]
        "ImplicitCommitSync"=""
        "MaxBufferSize"=dword:00000800
        "PageTimeout"=dword:00000005
        "Threads"=dword:00000003
        "UserCommitSync"="Yes"
    #>
    
    $registryValues = @(
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources'; ValueName = 'SO_Data_Reader'; ValueType = 'String'; ValueData = 'Microsoft Access Driver (*.mdb, *.accdb)'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'Driver'; ValueType = 'String'; ValueData = 'C:\\PROGRA~1\\COMMON~1\\MICROS~1\\OFFICE14\\ACEODBC.DLL'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'DBQ'; ValueType = 'String'; ValueData = $AccdbDatabasePath; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'DriverId'; ValueType = 'Dword'; ValueData = '19'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'FIL'; ValueType = 'String'; ValueData = 'MS Access'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'PWD'; ValueType = 'String'; ValueData = ''; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'SafeTransactions'; ValueType = 'Dword'; ValueData = '0'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader'; ValueName = 'UID'; ValueType = 'String'; ValueData = ''; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines\Jet'; ValueName = 'ImplicitCommitSync'; ValueType = 'String'; ValueData = ''; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines\Jet'; ValueName = 'MaxBufferSize'; ValueType = 'Dword'; ValueData = '2048'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines\Jet'; ValueName = 'PageTimeout'; ValueType = 'Dword'; ValueData = '5'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines\Jet'; ValueName = 'Threads'; ValueType = 'Dword'; ValueData = '3'; }
        @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\SO_Data_Reader\Engines\Jet'; ValueName = 'UserCommitSync'; ValueType = 'String'; ValueData = 'Yes'; }
    )
    
    foreach ($registryValue in $registryValues) {
        Registry "OBDC_$($registryValue.ValueName)" {
            Key = $registryValue.Key;
            ValueName = $registryValue.ValueName;
            ValueData = $registryValue.ValueData;
            ValueType = $registryValue.ValueType;
            Ensure = 'Present';
        }
    } #end foreach registry value
    
} #end configuration vShowcaseLabAccdbOdbc
