## flake 
Its the same workflow as my xfce Nix configuration. I just want darwin because MacOS is for people that probably do actual work.

```sh
cd ~/git/darwin-config
nix run nix-darwin -- switch --flake .#will-mac
```


```sh
darwin-rebuild switch --flake ~/git/darwin-config#will-mac
```

