.PHONY: help
help :
	@echo
	@echo 'Commands:'
	@echo
	@echo '  make test                  run unit tests'
	@echo '  make lint                  run linter'
	@echo '  make format                run code formatter, giving a diff for recommended changes'
	@echo '  make doc                   make documentation'
	@echo '  make changelog             update changelog based on version'
	@echo '  make pypi-dist             make binary and source packages for PyPI'
	@echo '  make pypi-dist-check       verify binary and source packages for PyPI'
	@echo '  make pypi-upload           upload to PyPI'
	@echo '  make conda-build           make binary and source packages for conda-forge'
	@echo '  make conda-upload          upload to conda-forge'
	@echo

VERSION ?= $(shell python setup.py --version)
REPO_URL = https://github.com/astronomy-commons/genesis-client

.PHONY: test
test :
	python -m pytest -v

.PHONY: lint
lint :
# stop the build if there are Python syntax errors or undefined names
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
# exit-zero treats all errors as warnings
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=100 --statistics

.PHONY: format
format :
# show diff via black
	black . --diff

.PHONY: doc
doc :
	cd doc && make html

.PHONY: changelog
changelog :
	sed -i 's@## \[Unreleased]@## \[Unreleased]\n\n## \[$(VERSION)] - $(shell date +'%Y-%m-%d')@' CHANGELOG.md
	sed -i 's@.*\[Unreleased]:.*@\[Unreleased]: $(REPO_URL)/compare/v$(VERSION)...HEAD\n[$(VERSION)]: $(REPO_URL)/releases/tag/v$(VERSION)@' CHANGELOG.md


.PHONY: pypi-dist
pypi-dist :
	python setup.py sdist bdist_wheel

.PHONY: pypi-dist-check
pypi-dist-check:
	twine check dist/*

.PHONY: pypi-upload
pypi-upload:
	twine upload dist/*

.PHONY: conda-build
conda-build:
	conda build -c defaults -c conda-forge ./recipe

.PHONY: conda-upload
conda-upload:
	anaconda upload $(shell conda build ./recipe --output)
