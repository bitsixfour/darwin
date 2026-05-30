## flake 
Its the same workflow as my xfce Nix configuration. I just want darwin because MacOS is for people that probably do actual work.

```sh
cd /etc/nixos
nix run nix-darwin -- switch --flake .#darwin
```


```sh
darwin-rebuild switch --flake /etc/nixos#darwin
```
