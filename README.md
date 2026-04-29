# Public-facing Me Portal
*Forked from https://github.com/ashki23/pandoc-bootstrap*

## Development

```
make watch
```

Under the hood this does;

Watch and rebuild (but you still get to refresh the browser): `./watch-render.sh`

... which in turn does `./build.sh`


## Deploy

```
make deploy
```

Using Cloudflare Pages, so BOOM, just link github repo - The generated index.html file *IS* the home page.

Depends on you comitting latest generated stuff (`build.sh`) to github. There is a pre-hook that checks this.

Cloudflare URL: https://carl-portal.pages.dev/


## Config Cloudflare Pages

cloudflare.com
- Pages
- create
- link to Github account
- Deploy to: /
