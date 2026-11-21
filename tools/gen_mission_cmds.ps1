# Builds App/Resources/MissionCommands.json for the mission editor from Mission Planner's own files:
#   - MAVLink.dll  MAVLink.MAV_CMD enum   (command name -> id)
#   - mavcmd.xml   per-vehicle command list with the labels of P1..P4, X(Lat), Y(Long), Z(Alt)
# REA Parity Source: MissionPlanner GCSViews/FlightPlanner.cs (cmdParamNames loaded from mavcmd.xml).
#
# Usage: powershell -File tools\gen_mission_cmds.ps1
param(
    [string]$MP = "C:\Program Files (x86)\Mission Planner",
    [string]$Out = (Join-Path $PSScriptRoot "..\App\Resources\MissionCommands.json")
)
$ErrorActionPreference = "Stop"
$asm = [Reflection.Assembly]::LoadFrom((Join-Path $MP "MAVLink.dll"))
$enum = $asm.GetType("MAVLink+MAV_CMD")
$ids = @{}
foreach ($n in $enum.GetEnumNames()) { $ids[$n] = [int]([Enum]::Parse($enum, $n)) }

[xml]$x = Get-Content (Join-Path $MP "mavcmd.xml") -Raw
$map = @{ "AC2" = "copter"; "APM" = "plane"; "APRover" = "rover" }
$result = [ordered]@{}
foreach ($veh in $x.CMD.ChildNodes) {
    if (-not $map.ContainsKey($veh.Name)) { continue }
    $list = New-Object System.Collections.ArrayList
    foreach ($c in $veh.ChildNodes) {
        if ($c.NodeType -ne "Element") { continue }
        if (-not $ids.ContainsKey($c.Name)) { Write-Warning "no MAV_CMD id for $($c.Name)"; continue }
        $labels = @()
        foreach ($t in "P1", "P2", "P3", "P4", "X", "Y", "Z") {
            $node = $c.SelectSingleNode($t)
            $labels += $(if ($node) { $node.InnerText.Trim() } else { "" })
        }
        [void]$list.Add([ordered]@{ id = $ids[$c.Name]; name = $c.Name; p = $labels })
    }
    $result[$map[$veh.Name]] = $list
}
New-Item -ItemType Directory -Force (Split-Path $Out) | Out-Null
$json = $result | ConvertTo-Json -Depth 5 -Compress
[IO.File]::WriteAllText($Out, $json, (New-Object System.Text.UTF8Encoding($false)))
foreach ($k in $result.Keys) { "$k : $($result[$k].Count) commands" }
