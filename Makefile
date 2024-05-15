install:
	flutter pub get

lint:
	dart analyze

lint-fix:
	dart fix --apply

check-format:
	dart format --output=none --set-exit-if-changed --line-length 120 .

format:
	dart format --line-length 120 .

build-apk:
	flutter build apk

tests:
	flutter test
