# Create asset directories
New-Item -ItemType Directory -Force -Path "assets\images"
New-Item -ItemType Directory -Force -Path "assets\animations"
New-Item -ItemType Directory -Force -Path "assets\audio"
New-Item -ItemType Directory -Force -Path "assets\fonts"

# Download placeholder sound effects (you'll need to replace these with actual sound files)
$soundUrls = @{
    "click.mp3" = "https://example.com/click.mp3"
    "correct.mp3" = "https://example.com/correct.mp3"
    "wrong.mp3" = "https://example.com/wrong.mp3"
    "level_complete.mp3" = "https://example.com/level_complete.mp3"
    "game_complete.mp3" = "https://example.com/game_complete.mp3"
}

foreach ($sound in $soundUrls.GetEnumerator()) {
    $outputPath = "assets\audio\$($sound.Key)"
    Write-Host "Downloading $($sound.Key)..."
    # Note: You'll need to replace these URLs with actual sound files
    # Invoke-WebRequest -Uri $sound.Value -OutFile $outputPath
}

Write-Host "Asset setup complete!" 