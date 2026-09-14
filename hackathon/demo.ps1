$projectRoot = Split-Path -Parent $PSScriptRoot

function Invoke-DemoStep {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Label,
    [Parameter(Mandatory = $true)]
    [string[]] $MoonArguments,
    [int] $ExpectedExitCode = 0
  )

  Write-Host "`n== $Label =="
  & moon @MoonArguments
  $observedExitCode = $LASTEXITCODE
  if ($observedExitCode -ne $ExpectedExitCode) {
    throw "$Label returned $observedExitCode; expected $ExpectedExitCode"
  }
}

Push-Location -LiteralPath $projectRoot
try {
  Invoke-DemoStep -Label 'Native test suite' -MoonArguments @(
    'test', '--target', 'native'
  )
  Invoke-DemoStep -Label 'Deterministic Markdown report' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'report', 'examples/minimal/canonical-clean.json'
  )
  Invoke-DemoStep -Label 'Deterministic JSON report' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'report', 'examples/minimal/canonical-clean.json', '--format', 'json'
  )
  Invoke-DemoStep -Label 'RoboSyn skipped-candidate audit' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'validate', 'examples/robosyn/evaluation-metrics-anonymized.json'
  ) -ExpectedExitCode 1
  Invoke-DemoStep -Label 'Deliberately malformed audit fixture' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'validate', 'examples/minimal/audit-findings.json'
  ) -ExpectedExitCode 1
  Invoke-DemoStep -Label 'Skipped and retry disclosure' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'audit', 'examples/minimal/skipped-and-retries.json'
  ) -ExpectedExitCode 1
  Invoke-DemoStep -Label 'JSONL normalization' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'summarize', 'examples/minimal/episodes.jsonl'
  )
  Invoke-DemoStep -Label 'CSV normalization' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'summarize', 'examples/minimal/episodes.csv'
  )
  Invoke-DemoStep -Label 'Protocol incompatibility protection' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'compare',
    'examples/incompatible-protocols/pure-observation.json',
    'examples/incompatible-protocols/public-pose.json'
  )
  Invoke-DemoStep -Label 'Sorted byte-level manifest' -MoonArguments @(
    'run', '--target', 'native', 'cmd/main', '--',
    'manifest',
    'examples/minimal/episodes.csv',
    'examples/minimal/episodes.jsonl'
  )
  Write-Host "`nRoboAudit demo completed successfully."
} finally {
  Pop-Location
}
