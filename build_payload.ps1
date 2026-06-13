$c = Get-Content C:\workspace\Baby\lib\screens\settings_screen.dart -Raw -Encoding UTF8
$b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($c))
$sha = 'e1f3c3bd8ccdb8dce95f05149394d46545e008e1'
$body = @{message='fix: settings RefreshIndicator';content=$b64;sha=$sha;branch='master'} | ConvertTo-Json

[System.IO.File]::WriteAllText('C:\workspace\Baby\payload.json', $body, [System.Text.UTF8Encoding]::new($false))
Write-Host 'done'
