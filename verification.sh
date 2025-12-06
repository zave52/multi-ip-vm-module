#!/bin/bash

set -e

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting network verification script..."

log "Verifying IP rules..."
if ip rule show | grep -q "from"; then
  log "SUCCESS: IP rules are present."
  ip rule show
else
  log "FAILURE: IP rules are missing."
  exit 1
fi

log "Verifying IP addresses..."
if ip -4 addr show eth0 | grep -q "inet"; then
  log "SUCCESS: IP addresses are configured on eth0."
  ip -4 addr show eth0
else
  log "FAILURE: No IP addresses found on eth0."
  exit 1
fi

log "Testing outbound connectivity for each private IP..."

if [ ! -f /tmp/ip_mappings.json ]; then
  log "FAILURE: /tmp/ip_mappings.json not found."
  exit 1
fi

PRIVATE_IPS=($(jq -r '.[].private_ip' /tmp/ip_mappings.json))

if [ ${#PRIVATE_IPS[@]} -eq 0 ]; then
  log "FAILURE: Could not find any private IPs in /tmp/ip_mappings.json."
  exit 1
fi

log "Found private IPs: ${PRIVATE_IPS[*]}"

ALL_SUCCESS=true

for IP in "${PRIVATE_IPS[@]}"; do
  log "Testing from private IP: $IP..."

  EXPECTED_PUBLIC_IP=$(jq -r --arg private_ip "$IP" '.[] | select(.private_ip == $private_ip) | .public_ip' /tmp/ip_mappings.json)

  if [ -z "$EXPECTED_PUBLIC_IP" ]; then
    log "WARNING: No public IP found for private IP $IP in mappings file."
    continue
  fi

  # `https://ifconfig.co` returned a Cloudflare challenge (header `cf-mitigated: challenge`) when run from cloud VMs,
  # so curl cannot solve the JS/CAPTCHA. Switched to `https://ifconfig.me` which returns a plain IP
  ACTUAL_PUBLIC_IP=$(curl -s --interface "$IP" https://ifconfig.me 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')

  if [ -z "$ACTUAL_PUBLIC_IP" ]; then
    log "FAILURE: Could not determine public IP for $IP (service failed or returned invalid data)"
    ALL_SUCCESS=false
    continue
  fi

  if [ "$ACTUAL_PUBLIC_IP" == "$EXPECTED_PUBLIC_IP" ]; then
    log "SUCCESS: Outbound request from $IP used public IP: $ACTUAL_PUBLIC_IP"
  else
    log "FAILURE: Outbound request from $IP used public IP: $ACTUAL_PUBLIC_IP, but expected: $EXPECTED_PUBLIC_IP"
    ALL_SUCCESS=false
  fi
done

log ""
if [ "$ALL_SUCCESS" = true ]; then
  log "Final Result: All public IPs are functional."
else
  log "Final Result: Some public IP checks failed."
fi
log "Verification complete."
