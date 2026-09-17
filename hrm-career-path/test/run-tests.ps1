param(
    [string]$TomcatHome = 'D:/TomCat10',
    [string]$AntHome = 'D:/Netbean17/NetBeans-17/netbeans/extide/ant'
)

# Build ứng dụng rồi chạy test trên database tạm; tuyệt đối không chạy script reset HRM.
$ErrorActionPreference = 'Stop'
$testProjectRoot = Split-Path -Parent $PSScriptRoot
$testOutput = Join-Path ([IO.Path]::GetTempPath()) ('hrm-module-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testOutput | Out-Null
Push-Location $testProjectRoot
try {
    & (Join-Path $AntHome 'bin/ant.bat') "-Dj2ee.server.home=$TomcatHome" dist
    if ($LASTEXITCODE -ne 0) { throw 'Build failed' }

    $testClasspath = "build/web/WEB-INF/classes;build/web/WEB-INF/lib/*;$TomcatHome/lib/*;$TomcatHome/bin/tomcat-juli.jar;$testOutput"
    & javac -encoding UTF-8 -source 17 -target 17 -cp $testClasspath -d $testOutput test/TestModuleIntegrationTest.java test/TestModuleHttpTest.java
    if ($LASTEXITCODE -ne 0) { throw 'Test compilation failed' }

    & java -cp $testClasspath TestModuleIntegrationTest
    if ($LASTEXITCODE -ne 0) { throw 'SQL Server integration tests failed' }

    & java -cp $testClasspath TestModuleHttpTest
    if ($LASTEXITCODE -ne 0) { throw 'HTTP tests failed' }
} finally {
    Pop-Location
}
