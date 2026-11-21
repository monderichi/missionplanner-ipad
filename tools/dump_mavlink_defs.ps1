# Extracts the MAVLink message table from the locally installed Mission Planner
# (MAVLink.dll) into tools/mavlink_defs.json. This is the "source of truth" the
# Swift code generator (tools/gen_swift.py) uses, so the iPad app uses exactly the
# same message IDs, CRC_EXTRA bytes, lengths and field layouts as Mission Planner.
#
# Usage (Windows PowerShell):  powershell -File tools\dump_mavlink_defs.ps1
param(
    [string]$Dll = "C:\Program Files (x86)\Mission Planner\MAVLink.dll",
    [string]$Out = (Join-Path $PSScriptRoot "mavlink_defs.json")
)
$ErrorActionPreference = "Stop"
$asm = [Reflection.Assembly]::LoadFrom($Dll)
$mav = $asm.GetType("MAVLink")
$infos = $mav.GetField("MAVLINK_MESSAGE_INFOS").GetValue($null)
$marshal = [System.Runtime.InteropServices.Marshal]

$msgs = foreach ($i in $infos) {
    $ty = $i.type
    if ($null -eq $ty) { continue }
    $fields = foreach ($f in $ty.GetFields()) {
        if ($f.IsStatic) { continue }
        $off = [int]$marshal::OffsetOf($ty, $f.Name)
        $ft = $f.FieldType
        $arr = 0
        $elem = $ft
        if ($ft.IsArray) {
            $elem = $ft.GetElementType()
            $ma = $f.GetCustomAttributesData() | Where-Object { $_.AttributeType.Name -eq "MarshalAsAttribute" }
            $sc = $ma.NamedArguments | Where-Object { $_.MemberName -eq "SizeConst" }
            $arr = [int]$sc.TypedValue.Value
        }
        $enum = ""
        $ea = $f.GetCustomAttributesData() | Where-Object { $_.AttributeType.Name -eq "MavEnumAttribute" -or $_.AttributeType.Name -eq "Enum" }
        [pscustomobject]@{ name = $f.Name; type = $elem.Name; offset = $off; array = $arr }
    }
    [pscustomobject]@{
        id = [int]$i.msgid; name = $i.name; crc = [int]$i.crc
        minlength = [int]$i.minlength; length = [int]$i.length
        fields = @($fields | Sort-Object offset)
    }
}
$json = $msgs | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($Out, $json, (New-Object System.Text.UTF8Encoding($false)))
"Wrote $($msgs.Count) messages from $($asm.FullName) to $Out"
