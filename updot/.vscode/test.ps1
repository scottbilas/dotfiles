$root = split-path -parent (split-path -parent $PSCommandPath)
cd $root
. ./.venv/Scripts/activate.ps1

# local
./.venv/Scripts/python.exe -m pytest --tb=short
write-host

# FUTURE: skip wsl if local fails (?)

# wsl
$wslroot = $root.replace('C:', '/c').replace('\', '/')
bash -c "cd $wslroot; source .wslenv/bin/activate; py3clean .; python -m pytest --tb=short; py3clean ."
