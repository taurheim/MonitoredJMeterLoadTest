# Download the zip from a test run
function GetTestResultsZipUri($headers, $RunId, $CltAccountUrl)
{
    # Load dependent files for execution
    . $PSScriptRoot/CltTasksUtility.ps1

    # Get the test drop containing the zip file
    $testRunUri = [String]::Format("{0}/_apis/clt/testruns/{1}?{2}", $CltAccountUrl, $RunId, $global:apiVersion)
    $testRunResponse = InvokeRestMethod -contentType "application/json" -uri $testRunUri -headers $headers

    # Get the test drop information
    $testDropId = $testRunResponse.testDrop.id
    $testDropUri = [String]::Format("{0}/_apis/clt/testdrops/{1}?{2}", $CltAccountUrl, $testDropId, $global:apiVersion)
    $testDropResponse = InvokeRestMethod -contentType "application/json" -uri $testDropUri -headers $headers

    # Get the uri with which we can download the zip
    $dropContainerUrl = $testDropResponse.accessData.dropContainerUrl
    $dropContainerUrl = $dropContainerUrl.replace($testDropResponse.id, $testDropResponse.testRunId)
    $dropContainerAuth = $testDropResponse.accessData.sasKey
    $resultsZipUri = [String]::Format("{0}/TestResult/ResultsArchive.zip{1}", $dropContainerUrl, $dropContainerAuth)

    return $resultsZipUri
}

function GetResultsCsvPath($headers, $zipUri)
{
    $resultsZipFile = "./Results.zip"
    $resultsExtractedFolder = "./Results"
    $resultsCsvNamingConvention = "Results*.csv"

    # Download the zip
    Invoke-WebRequest -Uri $zipUri -OutFile $resultsZipFile

    # Unzip
    Expand-Archive $resultsZipFile -DestinationPath $resultsExtractedFolder

    $resultsCsvPath = (Get-ChildItem -Path $resultsExtractedFolder -Filter $resultsCsvNamingConvention).FullName

    return $resultsCsvPath
}
