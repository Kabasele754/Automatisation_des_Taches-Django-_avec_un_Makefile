# Makefile pour gérer un projet Django

.PHONY: help venv install create_project run migrate shell createsuperuser test makemigrations collectstatic check lint coverage clean freeze startapp dbbackup dbrestore

# Détection automatique de l'OS
ifeq ($(OS),Windows_NT)
    PYTHON := python
    VENV := venv
    VENV_ACTIVATE := $(VENV)\Scripts\activate
    MANAGE := $(VENV)\Scripts\python manage.py
    PIP := $(VENV)\Scripts\pip
    FIND := where
    RM := del /Q
    RMDIR := rmdir /S /Q
    PIP_FREEZE := $(VENV)\Scripts\pip freeze > requirements.txt
    DB_BACKUP := $(MANAGE) dbbackup
    DB_RESTORE := $(MANAGE) dbrestore --input
else
    PYTHON := python3
    VENV := venv
    VENV_ACTIVATE := . $(VENV)/bin/activate
    MANAGE := $(VENV_ACTIVATE) && $(PYTHON) manage.py
    PIP := $(VENV)/bin/pip
    FIND := find
    RM := rm -f
    RMDIR := rm -rf
    PIP_FREEZE := $(VENV_ACTIVATE) && pip freeze > requirements.txt
    DB_BACKUP := $(MANAGE) dbbackup
    DB_RESTORE := $(MANAGE) dbrestore --input
endif

help:
	@echo "Usage:"
	@echo "  make [command]"
	@echo ""
	@echo "Commands:"
	@echo "  venv             Create a virtual environment"
	@echo "  install          Install dependencies"
	@echo "  create_project   Create a new Django project"
	@echo "  run              Run the development server"
	@echo "  migrate          Apply database migrations"
	@echo "  shell            Start Django shell"
	@echo "  createsuperuser  Create a superuser"
	@echo "  test             Run tests"
	@echo "  makemigrations   Create new migrations"
	@echo "  collectstatic    Collect static files"
	@echo "  check            Check for any problems"
	@echo "  lint             Run flake8 linter"
	@echo "  coverage         Run tests with coverage"
	@echo "  clean            Remove Python file artifacts"
	@echo "  freeze           Generate requirements.txt from installed packages"
	@echo "  startapp         Create a new Django app"
	@echo "  dbbackup         Backup the database"
	@echo "  dbrestore        Restore the database from a backup"

venv:
	$(PYTHON) -m venv $(VENV)
	$(VENV_ACTIVATE) && $(PIP) install --upgrade pip

install: venv
	@if [ ! -f requirements.txt ]; then \
		echo "Error: requirements.txt not found."; \
		exit 1; \
	fi
	$(VENV_ACTIVATE) && $(PIP) install -r requirements.txt

create_project: venv
	@read -p "Enter project name: " project_name; \
	$(VENV_ACTIVATE) && $(PYTHON) -m django startproject $$project_name .; \
	echo "django" > requirements.txt; \
	$(PIP_FREEZE)

run:
	$(MANAGE) runserver

migrate:
	$(MANAGE) migrate

shell:
	$(MANAGE) shell

createsuperuser:
	$(MANAGE) createsuperuser

test:
	$(MANAGE) test

makemigrations:
	$(MANAGE) makemigrations

collectstatic:
	$(MANAGE) collectstatic --noinput

check:
	$(MANAGE) check

lint:
	$(VENV_ACTIVATE) && flake8 .

coverage:
	$(VENV_ACTIVATE) && coverage run --source='.' manage.py test
	$(VENV_ACTIVATE) && coverage report

clean:
	$(FIND) . -type f -name "*.pyc" -exec $(RM) {} +
	$(FIND) . -type d -name "__pycache__" -exec $(RMDIR) {} +

freeze:
	$(PIP_FREEZE)

startapp:
	@read -p "Enter app name: " app_name; \
	$(VENV_ACTIVATE) && $(MANAGE) startapp $$app_name

dbbackup:
	$(DB_BACKUP)

dbrestore:
	$(DB_RESTORE) $(file)
