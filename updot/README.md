=== readme tbd

development fun: (todo: make me into setup.py or whatev)

(re-)create virtual environment:

```sh
deactivate
rm -rf .venv
python3 -m venv .venv
# bash
source .venv/bin/activate
# fish
source .venv/bin/activate.fish
# posh
. .venv/scripts/activate.ps1
pip install -r requirements.txt -r test_requirements.txt
```
