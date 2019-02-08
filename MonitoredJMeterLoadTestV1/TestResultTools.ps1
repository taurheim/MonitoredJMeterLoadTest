# Returns a value from 0 to 100
function GetErrorPercentage($csvPath) {
    $totalErrors = 0

    $successes = Get-Content $csvPath | ConvertFrom-Csv | Select-Object success -ExpandProperty success

    foreach ($success in $successes) {
        if ($success -ne "true") {
            $totalErrors++;
        }
    }

    return 100 * ($totalErrors / $successes.Count)
}

# Expects percentile as an int from 0 to 100
# TODO Make this more performant:
# Use IntroSelect algorithm: http://yongblog.us/2017/02/02/nth-element-Introselect/
function GetPercentileResponseTime($csvPath, $percentile) {
    $elapsedTimes = Get-Content $csvPath | ConvertFrom-Csv | Select-Object elapsed -ExpandProperty elapsed | ForEach-Object {[convert]::ToInt32($_, 10)} | Sort-Object
    $percentileIndex = $elapsedTimes.Count * ($percentile / 100);
    return $elapsedTimes[$percentileIndex - 1];
}
