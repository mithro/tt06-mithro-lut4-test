
TOP_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

export TTSETUP := $(TOP_DIR)/ttsetup
export OPENLANE_ROOT := $(TTSETUP)/openlane
export PDK_ROOT := $(TTSETUP)/pdk
export PDK := sky130A
export OPENLANE_TAG := 2024.04.02
export OPENLANE_IMAGE_NAME := efabless/openlane:2024.04.02

.SUFFIXES:

SHELL := bash

tt:
	git clone -b tt06 https://github.com/TinyTapeout/tt-support-tools tt

$(TTSETUP)/venv: tt
	python -m venv $(TTSETUP)/venv
	source $(TTSETUP)/venv/bin/activate; pip install -r $(TOP_DIR)/tt/requirements.txt
	touch $(TTSETUP)/venv

$(OPENLANE_ROOT):
	git clone --depth=1 --branch $(OPENLANE_TAG) https://github.com/The-OpenROAD-Project/OpenLane.git $(OPENLANE_ROOT)
	cd $(OPENLANE_ROOT); make

harden: $(TTSETUP)/venv $(OPENLANE_ROOT)
	source $(TTSETUP)/venv/bin/activate && ./tt/tt_tool.py --create-user-config && ./tt/tt_tool.py --harden && ./tt/tt_tool.py --print-warnings
