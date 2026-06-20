# Deployment Instructions

**Important:** Vercel is currently configured with a **Root Directory** value (`web home page`). This folder no longer exists, causing the 404 error.

1. Log in to Vercel → Dashboard → *Projects* → select **hassle‑free‑eight**.
2. Go to **Settings → General**.
3. In **Build & Output Settings → Root Directory**, **clear the field** (leave it blank). Save.
4. (Optional) Click **Clear Build Cache** in the Advanced Settings section.
5. Trigger a redeploy: go to **Deployments** tab → click the three‑dot menu on the latest deployment → **Redeploy**.

After the new build finishes, the site will be served from the repository root and the 404 will disappear.

The `vercel.json` file already contains only the API proxy rewrite:
```json
{
  "version": 2,
  "rewrites": [
    { "source": "/api/(.*)", "destination": "http://52.203.248.23/$1" }
  ]
}
```

Now you can push any future changes and Vercel will build the Next.js app correctly.
