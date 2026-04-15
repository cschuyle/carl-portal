# Public-facing Me Portal
*Forked from https://github.com/ashki23/pandoc-bootstrap*

Build: `./build.sh`

Watch and rebuild (but you still get to refresh the browser): `./watch-render.sh`


# Deploy

Cloudflare Pages, BOOM, just link github repo - generted index.html file *IS* the home page.

Depends on you comitting latest generated stuff (build.sh) to github.

Cloudflare URL: https://carl-portal.pages.dev/


# Config Cloudflare Pages

cloudflare.com, Pages, create, link to Github account

FORGOT: Deploy to: /

To fix supposedly:
```
npm install -g wrangler
wrangler login
wrangler pages deploy . --project-name carl-portal
```

BUT not working, frown.
