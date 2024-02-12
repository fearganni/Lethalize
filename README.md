# Lethalize

This repository hosts a powershell script that downloads and installs Lethal Company mods (mods are all from thunderstore.io).

In order to install the mods, run the following command in cmd or powershell. `windows key + r` `/` type `powershell`, then paste the following command.

```powershell
powershell -nop -ExecutionPolicy Bypass -c "Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://github.com/fearganni/Lethalize/releases/latest/download/Install.ps1')))) -ArgumentList @('-lcApi','3.4.5','-moreCompany','1.8.1','-moreSuits','1.4.1', '-moreEmotes', '1.3.3','-diversity', '1.1.10','-lateCompany', '1.0.11','-reservedSlotsCore', '1.8.17','-reservedWalkieSlot', '1.6.2','-reservedFlashlightSlot', '1.6.3','-shipLoot', '1.0.0','-coilHeadStare', '1.0.6')"
```

### What's the future of this project?

Well, lets be real. Downlaoding and running powershell scripts are pretty sketchy. I am now working on a full fledged mod loader called Lethalize Manager. You can find that here: https://github.com/fearganni/LethalizeManager
