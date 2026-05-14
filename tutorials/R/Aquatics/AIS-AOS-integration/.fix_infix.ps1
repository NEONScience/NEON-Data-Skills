$file = 'aquatic-data-product-integration.Rmd'
$lines = [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)

function Split-RLine {
    param([string]$line)
    # Returns array of [pscustomobject]@{ Text=...; IsLiteral=$true/$false }
    # IsLiteral means string or comment - DO NOT TRANSFORM
    $result = New-Object System.Collections.ArrayList
    $buf = ''
    $i = 0
    $n = $line.Length
    while ($i -lt $n) {
        $ch = $line[$i]
        if ($ch -eq '"' -or $ch -eq "'" -or $ch -eq '`') {
            if ($buf.Length -gt 0) { [void]$result.Add([pscustomobject]@{Text=$buf;IsLiteral=$false}); $buf='' }
            $quote = $ch
            $sb = [string]$ch
            $j = $i + 1
            while ($j -lt $n) {
                $cj = $line[$j]
                $sb += $cj
                if ($cj -eq '\' -and $j + 1 -lt $n) {
                    $j++
                    $sb += $line[$j]
                } elseif ($cj -eq $quote) {
                    break
                }
                $j++
            }
            [void]$result.Add([pscustomobject]@{Text=$sb;IsLiteral=$true})
            $i = $j + 1
        } elseif ($ch -eq '#') {
            if ($buf.Length -gt 0) { [void]$result.Add([pscustomobject]@{Text=$buf;IsLiteral=$false}); $buf='' }
            [void]$result.Add([pscustomobject]@{Text=$line.Substring($i);IsLiteral=$true})
            $i = $n
        } else {
            $buf += $ch
            $i++
        }
    }
    if ($buf.Length -gt 0) { [void]$result.Add([pscustomobject]@{Text=$buf;IsLiteral=$false}) }
    return $result
}

function Fix-Segment {
    param([string]$s)
    # Preserve leading whitespace
    if ($s -match '^(\s*)(.*)$') {
        $indent = $matches[1]
        $rest = $matches[2]
    } else {
        $indent = ''
        $rest = $s
    }
    # Operators in order: multi-char first
    # %...% operators (e.g., %>%, %in%)
    $rest = [regex]::Replace($rest, '(\S)(%[^%\s]*%)', '$1 $2')
    $rest = [regex]::Replace($rest, '(%[^%\s]*%)(\S)', '$1 $2')
    # <- and <<- and -> and ->>
    $rest = [regex]::Replace($rest, '(\S)(<<-|<-|->>|->)', '$1 $2')
    $rest = [regex]::Replace($rest, '(<<-|<-|->>|->)(\S)', '$1 $2')
    # == != <= >=
    $rest = [regex]::Replace($rest, '(\S)(==|!=|<=|>=)', '$1 $2')
    $rest = [regex]::Replace($rest, '(==|!=|<=|>=)(\S)', '$1 $2')
    # && ||
    $rest = [regex]::Replace($rest, '(\S)(&&|\|\|)', '$1 $2')
    $rest = [regex]::Replace($rest, '(&&|\|\|)(\S)', '$1 $2')
    # Single & and | (not part of && / ||) - use look-arounds
    $rest = [regex]::Replace($rest, '(?<=[^\s&|])(?<!&)&(?!&)', ' &')
    $rest = [regex]::Replace($rest, '(?<!&)&(?!&)(?=[^\s&|])', '& ')
    $rest = [regex]::Replace($rest, '(?<=[^\s&|])(?<!\|)\|(?!\|)', ' |')
    $rest = [regex]::Replace($rest, '(?<!\|)\|(?!\|)(?=[^\s&|])', '| ')
    # Single < and > (not part of <-, <<-, <=, ->, ->>, >=)
    $rest = [regex]::Replace($rest, '(?<=[^\s<>=!\-])<(?![<\-=])', ' <')
    $rest = [regex]::Replace($rest, '(?<![<\-=!])<(?![<\-=])(?=[^\s<>=])', '< ')
    $rest = [regex]::Replace($rest, '(?<=[^\s<>=\-])>(?![>=])', ' >')
    $rest = [regex]::Replace($rest, '(?<![\->=])>(?![>=])(?=[^\s<>=])', '> ')
    # Division /  (but not //) - rare in R; only pad when between word chars
    $rest = [regex]::Replace($rest, '(\w|\))/(\w|\()', { param($m) "$($m.Groups[1].Value) / $($m.Groups[2].Value)" })

    # Collapse multiple spaces to single (within non-leading)
    $rest = [regex]::Replace($rest, ' {2,}', ' ')
    # Trim trailing whitespace
    $rest = $rest -replace '\s+$',''
    return $indent + $rest
}

$inChunk = $false
$changed = 0
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^```\{r') { $inChunk = $true; continue }
    if ($inChunk -and $line -match '^```\s*$') { $inChunk = $false; continue }
    if (-not $inChunk) { continue }
    if ($line -match '^\s*$') { continue }

    $segs = Split-RLine -line $line
    $sb = ''
    $first = $true
    foreach ($seg in $segs) {
        if ($seg.IsLiteral) {
            $sb += $seg.Text
        } else {
            if ($first) {
                $sb += (Fix-Segment -s $seg.Text)
            } else {
                # mid-line non-literal: trim/fix without re-adding indent
                $fixed = Fix-Segment -s $seg.Text
                # remove any leading indent reconstruction since we are mid-line
                $sb += ($fixed -replace '^\s*','')
            }
        }
        $first = $false
    }
    if ($sb -ne $line) { $lines[$i] = $sb; $changed++ }
}

[System.IO.File]::WriteAllLines($file, $lines, [System.Text.Encoding]::UTF8)
Write-Host "Modified $changed lines"
