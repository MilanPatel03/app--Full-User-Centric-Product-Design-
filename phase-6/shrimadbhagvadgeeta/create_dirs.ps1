$base = "c:\Users\anime\Desktop\Flutter_folder\shrimadbhagvadgeeta"
$dirs = @(
  "lib\core\constants", "lib\core\errors", "lib\core\network", "lib\core\utils",
  "lib\features\chapters\domain\entities", "lib\features\chapters\domain\repositories", "lib\features\chapters\domain\usecases",
  "lib\features\chapters\data\models", "lib\features\chapters\data\mappers", "lib\features\chapters\data\datasources", "lib\features\chapters\data\repositories",
  "lib\features\chapters\presentation\providers", "lib\features\chapters\presentation\screens", "lib\features\chapters\presentation\widgets",
  "lib\features\shloks\domain\entities", "lib\features\shloks\domain\repositories", "lib\features\shloks\domain\usecases",
  "lib\features\shloks\data\models", "lib\features\shloks\data\mappers", "lib\features\shloks\data\datasources", "lib\features\shloks\data\repositories",
  "lib\features\shloks\presentation\providers", "lib\features\shloks\presentation\screens", "lib\features\shloks\presentation\widgets",
  "lib\features\bookmarks\domain\entities", "lib\features\bookmarks\domain\repositories", "lib\features\bookmarks\domain\usecases",
  "lib\features\bookmarks\data\datasources", "lib\features\bookmarks\data\repositories",
  "lib\features\bookmarks\presentation\providers", "lib\features\bookmarks\presentation\screens", "lib\features\bookmarks\presentation\widgets",
  "lib\features\collections\domain\entities", "lib\features\collections\domain\repositories", "lib\features\collections\domain\usecases",
  "lib\features\collections\data\datasources", "lib\features\collections\data\repositories",
  "lib\features\collections\presentation\providers", "lib\features\collections\presentation\screens", "lib\features\collections\presentation\widgets",
  "lib\features\search\domain\usecases", "lib\features\search\presentation\providers", "lib\features\search\presentation\screens",
  "lib\features\settings\domain\entities", "lib\features\settings\domain\repositories",
  "lib\features\settings\data\datasources", "lib\features\settings\data\repositories",
  "lib\features\settings\presentation\providers", "lib\features\settings\presentation\screens",
  "assets\google_fonts"
)
foreach ($d in $dirs) {
  $full = Join-Path $base $d
  New-Item -ItemType Directory -Force -Path $full | Out-Null
  Write-Host "Created: $d"
}
Write-Host "All directories created successfully."
