gen:
	fvm dart run build_runner build
.PHONY:gen

migrate:
	fvm dart run drift_dev make-migrations
.PHONY:migrate

lint:
	fvm dart fix --apply
.PHONY:lint

build-apk:
	pwsh.exe scripts/build-apk.ps1

gen-widget:
	cd widgetbook && fvm dart run build_runner build -d

test_about_use_page:
	fvm flutter test integration_test/about_us_page_test.dart

test_add_label_page:
	fvm flutter test integration_test/add_label_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_add_project_page:
	fvm flutter test integration_test/add_project_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_add_task_page:
	fvm flutter test integration_test/add_task_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_completed_tasks_page:
	fvm flutter test integration_test/completed_tasks_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_home_page:
	fvm flutter test integration_test/home_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_all: $(wildcard test_*)
	@echo "done".
.PHONY:integration_test