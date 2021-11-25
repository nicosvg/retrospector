default:
  just --list
release-prod:
  MIX_ENV=prod mix release
release-dev:
  MIX_ENV=dev mix release
build-docker:
  docker build -t microretro:latest .