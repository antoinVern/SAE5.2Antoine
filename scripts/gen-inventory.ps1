Param(
  [string]$VagrantDir = "vagrant",
  [string]$OutputFile = "inventory.ini"
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $VagrantDir)) {
  throw "Dossier Vagrant introuvable: $VagrantDir"
}

Push-Location $VagrantDir
try {
  $sshConfig = & vagrant ssh-config 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $sshConfig) {
    throw "Impossible d'exécuter 'vagrant ssh-config'. As-tu lancé 'vagrant up' ?"
  }
} finally {
  Pop-Location
}

function Get-HostBlock($config, $hostName) {
  $lines = $config -split "`n"
  $start = ($lines | Select-String -Pattern ("^Host\s+" + [regex]::Escape($hostName) + "\s*$") -SimpleMatch).LineNumber
  if (-not $start) { return $null }
  $startIdx = $start - 1
  $endIdx = $lines.Length - 1
  for ($i = $startIdx + 1; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\s*Host\s+') { $endIdx = $i - 1; break }
  }
  return $lines[$startIdx..$endIdx] -join "`n"
}

function Parse-SshConfigValue($block, $key) {
  $m = [regex]::Match($block, "^\s*$key\s+(.+?)\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}

$hosts = @(
  @{ vagrant="attaquant"; group="vm_attaquant" },
  @{ vagrant="fw"; group="vm_fw" },
  @{ vagrant="cible_dmz"; group="vm_cible_dmz" }
)

$out = @()
foreach ($h in $hosts) {
  $block = Get-HostBlock $sshConfig $h.vagrant
  if (-not $block) { throw "Host '$($h.vagrant)' non trouvé dans ssh-config." }

  $hostname = Parse-SshConfigValue $block "HostName"
  $user = Parse-SshConfigValue $block "User"
  $identityFile = Parse-SshConfigValue $block "IdentityFile"

  if (-not $hostname -or -not $user -or -not $identityFile) {
    throw "Entrées manquantes pour '$($h.vagrant)' (HostName/User/IdentityFile)."
  }

  $out += "[$($h.group)]"
  $out += "$($h.vagrant) ansible_host=$hostname ansible_user=$user ansible_ssh_private_key_file=$identityFile"
  $out += ""
}

$out += "[all:vars]"
$out += "ansible_python_interpreter=/usr/bin/python3"
$out += ""

$out -join "`n" | Set-Content -Encoding ascii -Path $OutputFile

Write-Host "Inventaire généré: $OutputFile"

