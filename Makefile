# Makefile for What Todo project

# Define variables
FLUTTER_CMD = fvm flutter
DART_CMD = fvm dart
SCRIPTS_DIR = scripts

.PHONY: help
help:  ## Display this help message
	@echo "What Todo Project - Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(word 1,$(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'

.PHONY: gen
gen:  ## Generate code using build_runner
	$(DART_CMD) run build_runner build

.PHONY: gen-widget
gen-widget:  ## Generate widget code using build_runner for widgetbook
	cd widgetbook && $(DART_CMD) run build_runner build -d

.PHONY: migrate
migrate:  ## Run drift migrations
	$(DART_CMD) run drift_dev make-migrations

.PHONY: lint
lint:  ## Apply dart fixes
	$(DART_CMD) fix --apply

.PHONY: clean
clean:  ## Clean flutter project
	$(FLUTTER_CMD) clean .

.PHONY: build-apk
build-apk:  ## Build Android APK
	pwsh.exe $(SCRIPTS_DIR)/build-apk.ps1

# Integration tests
.PHONY: test_about_use_page
test_about_use_page:  ## Run about us page integration test
	$(FLUTTER_CMD) test integration_test/about_us_page_test.dart

.PHONY: test_add_label_page
test_add_label_page:  ## Run add label page integration test
	$(FLUTTER_CMD) test integration_test/add_label_page_test.dart --machine --start-paused -d windows --dart-define=IS_TEST=true

.PHONY: test_add_project_page
test_add_project_page:  ## Run add project page integration test
	$(FLUTTER_CMD) test integration_test/add_project_page_test.dart --machine --start-paused -d windows --dart-define=IS_TEST=true

.PHONY: test_add_task_page
test_add_task_page:  ## Run add task page integration test
	$(FLUTTER_CMD) test integration_test/add_task_page_test.dart --machine --start-paused -d windows --dart-define=IS_TEST=true

.PHONY: test_completed_tasks_page
test_completed_tasks_page:  ## Run completed tasks page integration test
	$(FLUTTER_CMD) test integration_test/completed_tasks_page_test.dart --machine --start-paused -d windows --dart-define=IS_TEST=true

.PHONY: test_home_page
test_home_page:  ## Run home page integration test
	$(FLUTTER_CMD) test integration_test/home_page_test.dart --machine --start-paused -d windows --dart-define=IS_TEST=true

.PHONY: test_all
test_all: test_about_use_page test_add_label_page test_add_project_page test_add_task_page test_completed_tasks_page test_home_page  ## Run all integration tests
	@echo "All tests completed."

# Standard aliases
.PHONY: build
build: gen  ## Generate code and build

.PHONY: fix
fix: lint  ## Lint and fix code

.PHONY: test
test: test_all  ## Run all tests (alias for test_all)