# Web Fuzzing Guide

Content discovery and parameter fuzzing with ffuf, gobuster, and feroxbuster.

## Wordlists

Essential wordlists from SecLists:

| Wordlist | Path | Purpose |
|----------|------|---------|
| raft-medium-directories | `Discovery/Web-Content/raft-medium-directories.txt` | Directory discovery |
| raft-medium-files | `Discovery/Web-Content/raft-medium-files.txt` | File discovery |
| common.txt | `Discovery/Web-Content/common.txt` | Quick directory scan |
| api-endpoints | `Discovery/Web-Content/api/api-endpoints.txt` | API route discovery |
| burp-parameter-names | `Discovery/Web-Content/burp-parameter-names.txt` | Parameter fuzzing |
| raft-medium-words | `Discovery/Web-Content/raft-medium-words.txt` | General word fuzzing |
| subdomains-top1million | `Discovery/DNS/subdomains-top1million-5000.txt` | Subdomain brute force |

Install SecLists: `apt install seclists`

## ffuf — Fast Web Fuzzer

### Basic Directory Discovery

```bash
# Standard directory brute force
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
  -mc 200,201,301,302,307,401,403,405 -o ffuf_dirs.json -of json

# With extensions
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt \
  -e .php,.asp,.aspx,.jsp,.html,.js,.json,.xml,.txt,.bak,.old,.conf,.env \
  -mc 200,301,302,403 -o ffuf_files.json -of json

# Recursive scanning
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -recursion -recursion-depth 3 -mc 200,301,302 -o ffuf_recursive.json -of json
```

### Parameter Discovery

```bash
# GET parameter fuzzing
ffuf -u "https://target.com/api/endpoint?FUZZ=test" \
  -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -mc 200 -fs 1234 -o ffuf_params.json -of json

# POST parameter fuzzing
ffuf -u "https://target.com/api/endpoint" -X POST \
  -d "FUZZ=test" -H "Content-Type: application/x-www-form-urlencoded" \
  -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -mc 200 -fs 1234

# JSON body fuzzing
ffuf -u "https://target.com/api/endpoint" -X POST \
  -d '{"FUZZ":"test"}' -H "Content-Type: application/json" \
  -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -mc 200 -fs 1234
```

### Header Fuzzing

```bash
# Header name fuzzing
ffuf -u https://target.com/ -H "FUZZ: test" \
  -w /usr/share/seclists/Discovery/Web-Content/BurpSuite-ParamMiner/lowercase-headers \
  -mc 200 -fs 1234

# Host header fuzzing (virtual hosts)
ffuf -u https://$IP/ -H "Host: FUZZ.target.com" \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -mc 200 -fs 1234
```

### Advanced Techniques

```bash
# Two-position fuzzing (username:password)
ffuf -u https://target.com/login -X POST \
  -d "user=FUZZ1&pass=FUZZ2" \
  -w users.txt:FUZZ1 -w passwords.txt:FUZZ2 \
  -mc 200,302 -mode clusterbomb

# Filter by response size, words, lines
ffuf -u https://target.com/FUZZ -w wordlist.txt \
  -mc all -fw 42 -fl 10  # filter by word count and line count

# Rate limiting
ffuf -u https://target.com/FUZZ -w wordlist.txt -rate 50 -t 10

# With cookies/auth
ffuf -u https://target.com/FUZZ -w wordlist.txt \
  -H "Cookie: session=abc123" -H "Authorization: Bearer token123"

# Match by regex
ffuf -u https://target.com/FUZZ -w wordlist.txt -mr "admin|dashboard|config"
```

## gobuster — Directory/DNS Brute Force

```bash
# Directory mode
gobuster dir -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
  -t 50 -o gobuster_dirs.txt -x php,html,js,txt

# DNS subdomain mode
gobuster dns -d target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -t 50 -o gobuster_subs.txt

# VHOST mode
gobuster vhost -u https://target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -t 50 -o gobuster_vhosts.txt

# With auth and status codes
gobuster dir -u https://target.com -w wordlist.txt \
  -c "session=abc123" -s "200,204,301,302,307,401,403" -b ""
```

## feroxbuster — Recursive Content Discovery

```bash
# Recursive scan with auto-tune
feroxbuster -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
  -x php,html,js,json,txt -d 4 -t 50 --auto-tune -o ferox_results.txt

# With status code filtering
feroxbuster -u https://target.com -w wordlist.txt \
  -s 200,301,302,401,403 -x php,html -d 3

# Smart mode (auto-filter based on baseline)
feroxbuster -u https://target.com --smart -w wordlist.txt

# Extract links from pages
feroxbuster -u https://target.com --extract-links -w wordlist.txt
```

## Workflow: Systematic Content Discovery

1. **Quick scan** with `common.txt` wordlist to establish baseline
2. **Medium scan** with `raft-medium-directories.txt` for thorough coverage
3. **File discovery** with extensions relevant to the tech stack
4. **API endpoint discovery** with API-specific wordlists
5. **Parameter discovery** on interesting endpoints with Arjun or ffuf
6. **Recursive scan** on discovered directories with feroxbuster
7. **Virtual host discovery** if IP-based hosting is suspected

Always review results for:
- 403 responses (may be bypassable)
- Backup files (.bak, .old, .swp, ~)
- Configuration files (.env, .config, web.config, .htaccess)
- API documentation (swagger.json, openapi.yaml, graphql)
- Debug/test endpoints (/debug, /test, /phpinfo.php, /trace)
