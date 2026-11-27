$ws = "C:\Users\light\Documents\Trae-CN\temp_20261127_01"
$stage = Join-Path $ws "_stage_nanopim1-workspace"
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$stage\scripts","$stage\evidence","$stage\screenshots","$stage\build-info" | Out-Null

# scripts: root-level *.sh / *.ps1 / *.conf only (excludes subdirs)
Get-ChildItem $ws -File | Where-Object { $_.Extension -in '.sh','.ps1','.conf' } |
  Copy-Item -Destination "$stage\scripts\" -Force

# evidence: evidence.tgz + the whole evidence_out tree (reference-image extraction)
Copy-Item "$ws\evidence.tgz" "$stage\evidence\" -Force -ErrorAction SilentlyContinue
if (Test-Path "$ws\evidence_out") {
  Copy-Item "$ws\evidence_out" "$stage\evidence\evidence_out" -Recurse -Force
}

# screenshots: vm_*.png
Get-ChildItem $ws -File -Filter "vm_*.png" | Copy-Item -Destination "$stage\screenshots\" -Force

# build-info: *.img.txt and *.img.sha
Get-ChildItem $ws -File | Where-Object { $_.Name -like "*.img.txt" -or $_.Name -like "*.img.sha" } |
  Copy-Item -Destination "$stage\build-info\" -Force

Write-Output "=== STAGED TREE ==="
Get-ChildItem $stage -Recurse -File |
  Sort-Object FullName |
  ForEach-Object { "{0,8}  {1}" -f $_.Length, $_.FullName.Substring($stage.Length+1) }
Write-Output "=== counts ==="
"scripts:    " + (Get-ChildItem "$stage\scripts" -File).Count
"evidence:   " + (Get-ChildItem "$stage\evidence" -Recurse -File).Count
"screenshots:" + (Get-ChildItem "$stage\screenshots" -File).Count
"build-info: " + (Get-ChildItem "$stage\build-info" -File).Count
Write-Output "=== safety: no sensitive files staged? ==="
$bad = Get-ChildItem $stage -Recurse -File | Where-Object { $_.Name -in 'id_build','id_build.pub','kh_build' -or $_.Name -like '*.img.xz' }
if ($bad) { $bad | ForEach-Object { "LEAK: " + $_.FullName } } else { "OK: no id_build/kh_build/*.img.xz staged" }
