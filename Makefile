.PHONY: analyze test build-production brand-assets

analyze:
	flutter analyze

test:
	flutter test

build-production:
	bash tools/build_production_appbundle.sh

brand-assets:
	bash tools/export_brand_assets.sh
	flutter pub run flutter_launcher_icons
	flutter pub run flutter_native_splash:create

