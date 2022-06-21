  $file = "C:\Windows\System32\drivers\etc\hosts"
  $hostfile = Get-Content $file
  $hostfile += "172.16.0.201 centos.local centos mock"
  $hostfile += "172.16.0.203 ricmini.local ricmini"
  $hostfile += "172.16.0.207 ricServe.local ricServe baz-filer01"
  Set-Content -Path $file -Value $hostfile -Force

  net use \\baz-filer01\repo /user:rswanson Lemming!