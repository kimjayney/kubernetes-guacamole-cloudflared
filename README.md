# Cloudflare Zero trust + Kubernetes Guacamole + Traefik
- for Private access to guacamole with VPN

# System 
- Internet -> Cloudflare Zero trust VPN -> Traefik -> Guacamole Pod

# Works
- Guacamole System

# Not works
- guacamole Administration permission

# Not checked
- RDP communication

# Guacamole credentials
- `guacadmin` `admin`

# Tunnel create
```
cloudflared tunnel create example-tunnel
```
# Create Secret
```
kubectl create secret generic tunnel-credentials --from-file=/Users/jayney/.cloudflared/<tunnelid>.json
```
# Domain connect
```
cloudflared tunnel route dns example-tunnel guacamole.rainclab.net
```
# DNS
- CNAME guacamole.example.com -> Cloudflare Tunnel ID.cf

# Apply Cloudflared
```
cd cloudflare
kubectl apply -k . 
```

# Apply guacd
```
cd guacd
kubectl apply -k . 
```

# Change traefik domain
```
cd guacamoole
vim ingress.yaml
--- 
- host: guacamole.example.com <- Edit here ->
```

# Apply guacamole
```
cd guacamole
kubectl apply -k . 
```

# Apply traefik
```
cd traefik
kubectl 
```