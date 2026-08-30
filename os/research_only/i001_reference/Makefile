PYTHON ?= python3

.PHONY: build run verify clean
build:
	$(PYTHON) build.py
run: build
	$(PYTHON) run.py
verify: build
	$(PYTHON) verify.py
clean:
	$(PYTHON) -c "import shutil; shutil.rmtree('build', ignore_errors=True)"
