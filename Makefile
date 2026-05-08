build-web:
	flutter build web --release --no-tree-shake-icons

build-web-debug:
	flutter build web --no-tree-shake-icons

run-web:
	flutter run -d chrome --no-tree-shake-icons

clean:
	flutter clean && flutter pub get
