param ([string]$name)

{
  "[typst]": {
    "editor.formatOnSave": true
  }
}


$projects = Get-ChildItem -Directory | Select-Object -ExpandProperty Name

if ($projects -contains $name) {
    typst compile "$name/src/main.typ" "$name/out.pdf"
} else {
    Write-Host "Project $name not found. Existing projects:`n$($projects -join "`n")"
}