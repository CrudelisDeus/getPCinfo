  function monitores
  {
      [CmdletBinding()]
      PARAM (
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [String[]]$ComputerName = $env:ComputerName
      )
  
      #List of Manufacture Codes that could be pulled from WMI and their respective full names. Used for translating later down.
      $ManufacturerHash = @{ 
        "AAC" =	"AcerView";
        "ACR" = "Acer";
        "AOC" = "AOC";
        "AIC" = "AG Neovo";
        "APP" = "Apple Computer";
        "AST" = "AST Research";
        "AUO" = "Asus";
        "BNQ" = "BenQ";
        "CMO" = "Acer";
        "CPL" = "Compal";
        "CPQ" = "Compaq";
        "CPT" = "Chunghwa Pciture Tubes, Ltd.";
        "CTX" = "CTX";
        "DEC" = "DEC";
        "DEL" = "Dell";
        "DPC" = "Delta";
        "DWE" = "Daewoo";
        "EIZ" = "EIZO";
        "ELS" = "ELSA";
        "ENC" = "EIZO";
        "EPI" = "Envision";
        "FCM" = "Funai";
        "FUJ" = "Fujitsu";
        "FUS" = "Fujitsu-Siemens";
        "GSM" = "LG Electronics";
        "GWY" = "Gateway 2000";
        "HEI" = "Hyundai";
        "HIT" = "Hyundai";
        "HSL" = "Hansol";
        "HTC" = "Hitachi/Nissei";
        "HWP" = "HP";
        "IBM" = "IBM";
        "ICL" = "Fujitsu ICL";
        "IVM" = "Iiyama";
        "KDS" = "Korea Data Systems";
        "LEN" = "Lenovo";
        "LGD" = "Asus";
        "LPL" = "Fujitsu";
        "MAX" = "Belinea"; 
        "MEI" = "Panasonic";
        "MEL" = "Mitsubishi Electronics";
        "MS_" = "Panasonic";
        "NAN" = "Nanao";
        "NEC" = "NEC";
        "NOK" = "Nokia Data";
        "NVD" = "Fujitsu";
        "OPT" = "Optoma";
        "PHL" = "Philips";
        "REL" = "Relisys";
        "SAN" = "Samsung";
        "SAM" = "Samsung";
        "SBI" = "Smarttech";
        "SGI" = "SGI";
        "SNY" = "Sony";
        "SRC" = "Shamrock";
        "SUN" = "Sun Microsystems";
        "SEC" = "Hewlett-Packard";
        "TAT" = "Tatung";
        "TOS" = "Toshiba";
        "TSB" = "Toshiba";
        "VSC" = "ViewSonic";
        "ZCM" = "Zenith";
        "UNK" = "Unknown";
        "_YV" = "Fujitsu";
          }
      
  
      #Takes each computer specified and runs the following code:
      ForEach ($Computer in $ComputerName) {
  
        #Grabs the Monitor objects from WMI
        $Monitors = Get-WmiObject -Namespace "root\WMI" -Class "WMIMonitorID" -ComputerName $Computer -ErrorAction SilentlyContinue
    
        #Creates an empty array to hold the data
        $Monitor_Array = @()
    
    
        #Takes each monitor object found and runs the following code:
        ForEach ($Monitor in $Monitors) {
      
          #Grabs respective data and converts it from ASCII encoding and removes any trailing ASCII null values
          If ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName) -ne $null) {
            $Mon_Model = ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)","")
          } else {
            $Mon_Model = $null
          }
          $Mon_Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)","")
          $Mon_Attached_Computer = ($Monitor.PSComputerName).Replace("$([char]0x0000)","")
          $Mon_Manufacturer = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)","")
      
          #Filters out "non monitors". Place any of your own filters here. These two are all-in-one computers with built in displays. I don't need the info from these.
          If ($Mon_Model -like "*800 AIO*" -or $Mon_Model -like "*8300 AiO*") {Break}
      
          #Sets a friendly name based on the hash table above. If no entry found sets it to the original 3 character code
          $Mon_Manufacturer_Friendly = $ManufacturerHash.$Mon_Manufacturer
          If ($Mon_Manufacturer_Friendly -eq $null) {
            $Mon_Manufacturer_Friendly = $Mon_Manufacturer
          }
      
          #Creates a custom monitor object and fills it with 4 NoteProperty members and the respective data
          $Monitor_Obj = [PSCustomObject]@{
            Manufacturer     = $Mon_Manufacturer_Friendly
            Model            = $Mon_Model
          }
      
          #Appends the object to the array
          $Monitor_Array += $Monitor_Obj

        } #End ForEach Monitor
  
        #Outputs the Array
        $Monitor_Array
    
    } #End ForEach Computer
}


clear
$ramSize = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
$motherboard = Get-CimInstance Win32_BaseBoard 
$pc = Get-CimInstance Win32_ComputerSystem
$proc = Get-WmiObject win32_Processor
$t = "'t"
$memory = Get-CimInstance Win32_PhysicalMemory
$disk = Get-Disk
$videoContoller = Get-WmiObject win32_VideoController
$ipv4 = Get-NetIPAddress -AddressFamily IPv4
Write-Host "UserName: " -NoNewline -ForegroundColor Yellow
Write-Host $env:UserName -ForegroundColor green
Write-Host "PC-Name: " -NoNewline -ForegroundColor Yellow
Write-Host $pc.Caption -ForegroundColor green
Write-Host "Ipv4: " -NoNewline -ForegroundColor Yellow
Write-Host $ipv4 -ForegroundColor green
Write-Host "Domain: " -NoNewline -ForegroundColor Yellow
Write-Host $pc.Domain -ForegroundColor green
Write-Host `n"Video controller: " -NoNewline -ForegroundColor Yellow
Write-Host $videoContoller.Name -ForegroundColor green
Write-Host `n"Processor name: " -NoNewline -ForegroundColor Yellow
Write-Host $proc.Name -ForegroundColor green
Write-Host "Number of Cores: " -NoNewline -ForegroundColor Yellow
Write-Host $proc.NumberOfCores -ForegroundColor green -NoNewline
Write-Host " Number of logical Processors: " -NoNewline -ForegroundColor Yellow
Write-Host $proc.NumberOfLogicalProcessors -ForegroundColor green
Write-Host `n"RAM: " -NoNewline -ForegroundColor Yellow
Write-Host $ramSize "GB" -ForegroundColor green
Write-Host "Model/s: " -NoNewline -ForegroundColor Yellow
Write-Host $memory.PartNumber -ForegroundColor green
Write-Host `n"Motherboard info: " -NoNewline -ForegroundColor Yellow
Write-Host $motherboard.Model $motherboard.Product -ForegroundColor green
Write-Host `n"Disck size: " -NoNewline -ForegroundColor Yellow
Write-Host ($disk.size/1gb) "GB" -ForegroundColor green
Write-Host "Model: " -NoNewline -ForegroundColor Yellow
Write-Host $disk.Model -ForegroundColor green
Write-Host `n"Monitor info: " -NoNewline -ForegroundColor Yellow
monitores
