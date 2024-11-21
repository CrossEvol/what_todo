gen:
	dart run build_runner build
.PHONY:gen

migrate:
	dart run drift_dev make-migrations
.PHONY:migrate

lint:
	dart fix --apply
.PHONY:lint

test_about_use_page:
	flutter test integration_test/about_us_page_test.dart

test_add_label_page:
	flutter test integration_test/add_label_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_add_project_page:
	flutter test integration_test/add_project_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_add_task_page:
	flutter test integration_test/add_task_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_completed_tasks_page:
	flutter test integration_test/completed_tasks_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_home_page:
	flutter test integration_test/home_page_test.dart --machine --start-paused -d windows  --dart-define=IS_TEST=true

test_all: $(wildcard test_*)
	@echo "done".
.PHONY:integration_test