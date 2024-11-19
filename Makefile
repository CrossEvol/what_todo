gen:
	dart run build_runner build
.PHONY:gen

migrate:
	dart run drift_dev make-migrations
.PHONY:migrate

lint:
	dart fix --apply
.PHONY:lint