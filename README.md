# Brr

```powershell
powershell -nop -ExecutionPolicy Bypass -c "Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://github.com/fearganni/Lethalize/releases/latest/download/Install.ps1')))) -ArgumentList @('-lcapi','2.2.0','-biggerlobby','2.6.0','-moresuits','1.4.1', '-moreemotes', '1.2.2', '-boomboxnopower', '1.0.0', '-nicerteleporters', '1.1.0')"
```
