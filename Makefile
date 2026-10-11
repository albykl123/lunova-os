# ==============================================================================
# Lunova OS 1.0 Aurora - Master Automation Makefile
# ==============================================================================

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help setup configure build test release clean check-env lint apps

help:
	@echo "=================================================================="
	@echo "  LUNOVA OS 1.0 AURORA — BUILD & AUTOMATION SYSTEM"
	@echo "=================================================================="
	@echo "  make check-env   - Verify host architecture, OS, and permissions"
	@echo "  make setup       - Install live-build, Qt5, and compilation tools"
	@echo "  make configure   - Generate live-build configurations"
	@echo "  make apps        - Compile native Qt/QML Lunova applications"
	@echo "  make build       - Build the complete bootable live ISO"
	@echo "  make test        - Run QEMU virtual machine test harness"
	@echo "  make release     - Verify SHA256 checksums and prepare release"
	@echo "  make lint        - Run static analysis and validation checks"
	@echo "  make clean       - Purge live-build cache and temporary files"
	@echo "=================================================================="

check-env:
	@chmod +x scripts/*.sh tests/*.sh 2>/dev/null || true
	@./scripts/bootstrap.sh

setup: check-env
	@./scripts/install-dependencies.sh

configure:
	@./scripts/configure.sh

apps:
	@echo "==> Building Lunova Native Applications locally..."
	@mkdir -p apps/lunova-welcome/build && cd apps/lunova-welcome/build && cmake .. && make -j$$(nproc 2>/dev/null || echo 2)
	@mkdir -p apps/lunova-about/build && cd apps/lunova-about/build && cmake .. && make -j$$(nproc 2>/dev/null || echo 2)
	@mkdir -p apps/lunova-control-center/build && cd apps/lunova-control-center/build && cmake .. && make -j$$(nproc 2>/dev/null || echo 2)
	@mkdir -p apps/lunova-assistant/build && cd apps/lunova-assistant/build && cmake .. && make -j$$(nproc 2>/dev/null || echo 2)
	@mkdir -p apps/lunova-update/build && cd apps/lunova-update/build && cmake .. && make -j$$(nproc 2>/dev/null || echo 2)

build:
	@./scripts/build-iso.sh

test:
	@./scripts/test-iso.sh

release:
	@./scripts/release.sh

lint:
	@echo "==> Validating configuration files and scripts..."
	@./tests/test_config.sh
	@./tests/test_branding.sh
	@./tests/test_scripts.sh

clean:
	@echo "==> Cleaning live-build workspace..."
	@lb clean --purge 2>/dev/null || true
	@rm -rf chroot binary .build auto/config auto/build auto/clean build.log
	@rm -rf apps/*/build
	@echo "==> Clean complete."
