# Process-local Android preparation. Default action never builds or invokes Flutter.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$JdkHome,
    [Parameter(Mandatory = $true)][string]$GradleUserHome,
    [Parameter(Mandatory = $true)][string]$AndroidSdkRoot,
    [ValidateSet('Check', 'BuildDemo')][string]$Action = 'Check'
)

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$JdkHome = (Resolve-Path -LiteralPath $JdkHome).Path
$AndroidSdkRoot = (Resolve-Path -LiteralPath $AndroidSdkRoot).Path
$GradleUserHome = [IO.Path]::GetFullPath($GradleUserHome)
if ($GradleUserHome.TrimEnd('\', '/') -eq $repoRoot -or
    $GradleUserHome.StartsWith($repoRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Choose a Gradle cache outside the checkout.'
}
if (-not (Test-Path -LiteralPath (Join-Path $JdkHome 'bin/javac.exe'))) {
    throw 'A complete JDK 17 is required.'
}
$release = Get-Content -LiteralPath (Join-Path $JdkHome 'release') -Raw
if ($release -notmatch '(?m)^JAVA_VERSION="17(?:\.|"|-)') {
    throw 'JdkHome must identify JDK 17; no SDK versions will be changed.'
}
if (-not (Test-Path -LiteralPath (Join-Path $AndroidSdkRoot 'platform-tools/adb.exe'))) {
    throw 'Android SDK platform-tools are missing.'
}

$names = @('JAVA_HOME', 'GRADLE_USER_HOME', 'ANDROID_HOME', 'ANDROID_SDK_ROOT', 'PATH')
$saved = @{}
foreach ($name in $names) { $saved[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
$probe = $null
$stream = $null
try {
    $env:JAVA_HOME = $JdkHome
    $env:GRADLE_USER_HOME = $GradleUserHome
    $env:ANDROID_HOME = $AndroidSdkRoot
    $env:ANDROID_SDK_ROOT = $AndroidSdkRoot
    $env:PATH = (Join-Path $JdkHome 'bin') + ';' + $saved['PATH']
    # Use the wrapper's nested cache layout and an exclusive file handle.
    $probeDir = Join-Path $GradleUserHome 'wrapper/dists/a01-write-probe'
    New-Item -ItemType Directory -Path $probeDir -Force | Out-Null
    $probe = Join-Path $probeDir ([guid]::NewGuid().ToString() + '.zip.lck')
    $stream = [IO.File]::Open($probe, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $stream.WriteByte(1)
    $stream.Dispose()
    $stream = $null
    Remove-Item -LiteralPath $probe
    $probe = $null
    Write-Output 'PASS: isolated Gradle cache supports nested lock-file creation.'
    & (Join-Path $JdkHome 'bin/java.exe') -version
    if ($LASTEXITCODE -ne 0) { throw 'java -version failed.' }
    & (Join-Path $JdkHome 'bin/javac.exe') -version
    if ($LASTEXITCODE -ne 0) { throw 'javac -version failed.' }

    $wrapper = Join-Path $repoRoot 'android/gradlew.bat'
    $gradleArgs = @('--console=plain', '--no-daemon', "-Dorg.gradle.java.home=$JdkHome")
    if ($Action -eq 'Check') {
        # --version only bootstraps the wrapper; it does not configure/build the app.
        & $wrapper @gradleArgs --version
        if ($LASTEXITCODE -ne 0) { throw 'Gradle wrapper version check failed.' }
        Write-Output 'CHECK ONLY: no Flutter command or APK build was run.'
    } else {
        # Invoke only after the other chat releases the checkout and prepares pub/codegen.
        foreach ($relative in @('.dart_tool/package_config.json', 'android/local.properties', '.flutter-plugins-dependencies')) {
            if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relative))) {
                throw "Missing $relative. Have the Flutter owner finish preparation first."
            }
        }
        $demoJson = Get-Content -LiteralPath (Join-Path $repoRoot 'config/demo.example.json') -Raw | ConvertFrom-Json
        if ($demoJson.APP_MODE -ne 'demo') { throw 'Expected demo.example.json to select demo mode.' }
        $defines = @($demoJson.PSObject.Properties | ForEach-Object {
            [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_.Name + '=' + [string]$_.Value))
        }) -join ','
        Push-Location -LiteralPath (Join-Path $repoRoot 'android')
        try {
            # Windows pub cache and checkout can be on different drives. Kotlin's
            # incremental path mapper fails across roots; keep this override local.
            & $wrapper @gradleArgs assembleDebug "-Pdart-defines=$defines" '-Ptarget=lib/main.dart' '-Pkotlin.incremental=false' '--init-script' (Join-Path $PSScriptRoot 'a01-flutter-inputs.gradle')
            if ($LASTEXITCODE -ne 0) { throw 'Demo APK build failed.' }
        } finally { Pop-Location }
    }
} finally {
    if ($null -ne $stream) { $stream.Dispose() }
    if ($null -ne $probe -and (Test-Path -LiteralPath $probe)) { Remove-Item -LiteralPath $probe }
    foreach ($name in $names) {
        if ($null -eq $saved[$name]) {
            Remove-Item -LiteralPath "Env:$name" -ErrorAction SilentlyContinue
        } else {
            [Environment]::SetEnvironmentVariable($name, $saved[$name], 'Process')
        }
    }
}
