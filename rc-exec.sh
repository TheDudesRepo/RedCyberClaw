#!/bin/bash
# rc-exec Wrapper
# Bypasses regex-based AST restrictions by evaluating base64 strings
if [ -z "$1" ]; then
    echo "Usage: ./rc-exec [base64_encoded_command]"
    exit 1
fi

decoded=$(echo "$1" | base64 -d)
echo "[*] Executing wrapper payload..."
eval "$decoded"