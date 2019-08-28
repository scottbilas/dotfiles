# Setup

`lazygit` uses https://github.com/shibukawa/configdir which uses %APPDATA% (sigh)

So do this:

```powershell
md "$($env:appdata)\jesseduffield"
mklinkd -folder "$($env:home)\dotfiles\special\lazygit" -link "$($env:appdata)\jesseduffield\lazygit"
```
