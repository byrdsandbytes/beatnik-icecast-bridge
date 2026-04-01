# Exposing Icecast with Cloudflare Tunnel

This guide walks you through securely exposing your local Icecast stream to the internet using a Cloudflare Tunnel (`cloudflared`). This method is completely secure, provides automatic HTTPS (SSL), and requires **no open ports** on your firewall or router.

## Prerequisites

1.  **A Cloudflare Account**: Create a free account at [Cloudflare.com](https://cloudflare.com/).
2.  **A Custom Domain**: A domain name (e.g., `yourdomain.com`).

## Setup Instructions

### Step 1: Add Your Domain to Cloudflare
Before creating a tunnel, Cloudflare needs to manage your domain's DNS.
1. Log in to your Cloudflare dashboard.
2. Click **Add a Site** and enter your custom domain name (e.g., `yourdomain.com`).
3. Select the **Free** plan and click **Continue**.
4. Cloudflare will scan your existing DNS records. Review them and click **Continue**.
5. Cloudflare will provide you with two **Nameservers** (e.g., `elsa.ns.cloudflare.com`). 
6. Go to your domain registrar (where you bought the domain, like Namecheap, GoDaddy, or Google Domains) and replace the existing nameservers with the ones Cloudflare provided.
7. Return to Cloudflare and click **Done, check nameservers**. This process can take anywhere from a few minutes to a few hours to propagate.

### Step 2: Access the Zero Trust Dashboard
Log in to your Cloudflare dashboard, choose your domain, and from the left-hand menu, click on **Zero Trust**. 
*(Note: If this is your first time using Zero Trust, you may be prompted to choose a free tier plan and link a payment method, but you won't be charged).*

### Step 3: Create a New Tunnel
1. In the Zero Trust dashboard, expand the **Networks** menu on the left and select **Tunnels**.
2. Click the **Add a tunnel** button.
3. Select **Cloudflared** as the connector type and click **Next**.
4. Give your tunnel a memorable name (e.g., `beatnik-icecast`) and click **Save tunnel**.

### Step 4: Get Your Tunnel Token
After creating the tunnel, you will be prompted to "Install and run a connector".
1. Choose **Docker** as your environment.
2. In the code snippet provided for Docker, locate the long token string. It usually looks like this:
   ```bash
   docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhbGciOiJIUzI1NiIsInR5cCI6IkpX...
   ```
3. Copy **ONLY** the token value (the long string of gibberish starting with `ey...`).
4. Paste this token into your project's `.env` file as the `TUNNEL_TOKEN` variable:
   ```env
   # .env
   TUNNEL_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpX...
   ```

### Step 5: Route Traffic to Icecast
Back in the Cloudflare Zero Trust dashboard, click **Next** at the bottom of the "Install and run a connector" page to configure routing.

1. **Public Hostname**:
   - **Subdomain**: Enter a subdomain for your stream (e.g., `stream` or `radio`).
   - **Domain**: Select your base domain from the dropdown.
   *(This creates the public URL: `https://stream.yourdomain.com`)*
2. **Service**:
   - **Type**: Select `HTTP`.
   - **URL**: Type exactly `icecast:8000`. (*This maps the tunnel to the Docker internal network hostname of the Icecast container*).
3. Click **Save hostname**.

### Step 6: Start the Service
Return to your terminal on the machine hosting the `beatnik-icecast-bridge`. Restart your Docker stack to spin up the new `cloudflared` tunnel container:

```bash
docker compose down
docker compose up -d
```

### Verification
Wait a few seconds, then verify the tunnel is "Healthy" in the Cloudflare Zero Trust dashboard under **Networks -> Tunnels**. You can now open a browser or media player and listen to your stream at your new HTTPS public URL!
