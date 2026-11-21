# Generates MAVLink test vectors using Mission Planner's own MAVLink.dll encoder
# (MAVLink.MavlinkParse.GenerateMAVLinkPacket10/20). For every message in the
# table it fills every field with random values, encodes a v1 and a v2 packet,
# and records the bytes plus the expected field values.
#
# The Swift tests (Packages/MAVLinkKit/Tests) decode these bytes and re-encode them,
# requiring byte-for-byte parity with Mission Planner.
#
# Usage:  powershell -File tools\make_fixtures.ps1
param(
    [string]$Dll = "C:\Program Files (x86)\Mission Planner\MAVLink.dll",
    [string]$Out = (Join-Path $PSScriptRoot "..\Packages\MAVLinkKit\Tests\MAVLinkKitTests\Fixtures\mp_packets.json"),
    [int]$Seed = 1234
)
$ErrorActionPreference = "Stop"
$asm = [Reflection.Assembly]::LoadFrom($Dll)
$mav = $asm.GetType("MAVLink")
$infos = $mav.GetField("MAVLINK_MESSAGE_INFOS").GetValue($null)
$parseType = $asm.GetType("MAVLink+MavlinkParse")
$parser = [Activator]::CreateInstance($parseType, @($false))
$msgIdType = $asm.GetType("MAVLink+MAVLINK_MSG_ID")
$gen10 = $parseType.GetMethod("GenerateMAVLinkPacket10")
$gen20 = $parseType.GetMethod("GenerateMAVLinkPacket20")
$rng = New-Object System.Random($Seed)
$inv = [Globalization.CultureInfo]::InvariantCulture

function New-RandomValue([Type]$t, [bool]$zero) {
    if ($zero) { return [Convert]::ChangeType(0, $t) }
    $b = New-Object byte[] 8
    $rng.NextBytes($b)
    switch ($t.Name) {
        "Byte"   { return $b[0] }
        "SByte"  { return [sbyte]([int]$b[0] - 128) }
        "UInt16" { return [BitConverter]::ToUInt16($b, 0) }
        "Int16"  { return [BitConverter]::ToInt16($b, 0) }
        "UInt32" { return [BitConverter]::ToUInt32($b, 0) }
        "Int32"  { return [BitConverter]::ToInt32($b, 0) }
        "UInt64" { return [BitConverter]::ToUInt64($b, 0) }
        "Int64"  { return [BitConverter]::ToInt64($b, 0) }
        # exactly representable values so text round-trips are lossless
        "Single" { return [single]($rng.Next(-80000, 80000) / 8.0) }
        "Double" { return [double]($rng.Next(-80000, 80000) / 8.0) }
    }
    throw "unhandled type $($t.Name)"
}

function Format-Value($v) {
    if ($v -is [single] -or $v -is [double]) { return $v.ToString("R", $inv) }
    return $v.ToString()
}

$fixtures = New-Object System.Collections.ArrayList
$seq = 0
foreach ($i in $infos) {
    $ty = $i.type
    if ($null -eq $ty) { continue }
    # variant 0: all random; variant 1: only first field set (exercises v2 zero truncation)
    foreach ($variant in 0, 1) {
        $box = [Activator]::CreateInstance($ty)
        $expected = [ordered]@{}
        $first = $true
        $fields = $ty.GetFields() | Where-Object { -not $_.IsStatic } |
            Sort-Object { [System.Runtime.InteropServices.Marshal]::OffsetOf($ty, $_.Name).ToInt32() }
        foreach ($f in $fields) {
            $zero = ($variant -eq 1 -and -not $first)
            $ft = $f.FieldType
            if ($ft.IsArray) {
                $ma = $f.GetCustomAttributesData() | Where-Object { $_.AttributeType.Name -eq "MarshalAsAttribute" }
                $n = [int](($ma.NamedArguments | Where-Object { $_.MemberName -eq "SizeConst" }).TypedValue.Value)
                $et = $ft.GetElementType()
                $arr = [Array]::CreateInstance($et, $n)
                $vals = @()
                for ($k = 0; $k -lt $n; $k++) { $v = New-RandomValue $et $zero; $arr.SetValue($v, $k); $vals += (Format-Value $v) }
                $f.SetValue($box, $arr)
                $expected[$f.Name] = $vals
            } else {
                $v = New-RandomValue $ft $zero
                $f.SetValue($box, $v)
                $expected[$f.Name] = (Format-Value $v)
            }
            $first = $false
        }
        $id = [Enum]::ToObject($msgIdType, [uint32]$i.msgid)
        $sysid = [byte](1 + ($seq % 250)); $compid = [byte](1 + (($seq * 7) % 250))
        $s = $seq % 256
        $v2 = [byte[]]$gen20.Invoke($parser, @($id, $box, $false, $sysid, $compid, $s))
        $entry = [ordered]@{
            id = [int]$i.msgid; name = $i.name; variant = $variant
            sysid = [int]$sysid; compid = [int]$compid; seq = $s
            v2 = ([BitConverter]::ToString($v2) -replace "-", "")
            fields = $expected
        }
        if ($i.msgid -lt 256) {
            $v1 = [byte[]]$gen10.Invoke($parser, @($id, $box, $sysid, $compid, $s))
            $entry.v1 = ([BitConverter]::ToString($v1) -replace "-", "")
        }
        [void]$fixtures.Add([pscustomobject]$entry)
        $seq++
    }
}
New-Item -ItemType Directory -Force (Split-Path $Out) | Out-Null
$json = $fixtures | ConvertTo-Json -Depth 6 -Compress
[IO.File]::WriteAllText($Out, $json, (New-Object System.Text.UTF8Encoding($false)))
"Wrote $($fixtures.Count) fixtures to $Out"
