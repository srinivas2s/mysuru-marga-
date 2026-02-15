$file = "client/src/App.jsx"
$content = Get-Content $file
$lucideIcons = @()
$otherImports = @()
$code = @()
$skipImports = @("./Categories", "./PlaceCard", "./AllComponents", "./AllPages", "./Supabase", "./App", "./FeedbackSection", "../data", "../lib/supabaseClient", "../components/Map")

foreach ($line in $content) {
    if ($line -match "^import .* from 'lucide-react';") {
        $icons = ($line -replace "import \{(.*)\} from 'lucide-react';", "$1").Split(',') | ForEach-Object { $_.Trim() }
        $lucideIcons += $icons
    } elseif ($line -match "^import ") {
        $shouldSkip = $false
        foreach ($skip in $skipImports) {
            if ($line -match [regex]::Escape($skip)) { $shouldSkip = $true; break }
        }
        if (-not $shouldSkip) { $otherImports += $line }
    } elseif ($line -notmatch "^export default ") {
        $code += $line
    }
}

$uniqueIcons = $lucideIcons | Select-Object -Unique | Where-Object { $_ -ne "" }
$finalImports = @("import React, { useState, useEffect, useRef } from 'react';")
$finalImports += "import { " + ($uniqueIcons -join ", ") + " } from 'lucide-react';"
$finalImports += $otherImports | Select-Object -Unique
$finalImports + $code + "export default App;" | Set-Content $file -Encoding utf8
