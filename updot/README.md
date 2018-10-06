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

testing:

`python -m pytest --pylint --pylint-rcfile=setup.cfg`

=== guidance

* avoid any platform-specific branching, to keep rules simple. for example, we could permit backslashes in absolute Windows paths (because those kinds of paths aren't xplat compatible anyway) but that adds rules and logic. prefer consistency and a smaller set of rules.
* detect and warn about potential error sources from bugs in scripts
* even though the script is python, keep it scripty and follow bashy conventions. for example, python's `os.symlink` is the reverse of `ln`. stay with the ordering in `ln`.

=== future

static and runtime type checking to consider (via https://docs.python.org/3/library/typing.html):

* https://github.com/python/mypy (may need to switch out pylint, which doesnt fully hit PEP484, for flake8 + flake8-mypy)
* https://pypi.python.org/pypi/typecheck-decorator
* https://github.com/agronholm/typeguard
* https://github.com/google/pytype (requires 2.7 to run)
