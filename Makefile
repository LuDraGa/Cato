.PHONY: analyze test build-production brand-assets rebrand

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

# Rebrand package id (and optional display name).
#   make rebrand PACKAGE=dev.ludraga.cato
#   make rebrand PACKAGE=dev.ludraga.cato NAME="Cato"
rebrand:
	@if [ -z "$(PACKAGE)" ]; then echo "PACKAGE=<reverse.dns.id> required"; exit 1; fi
	@bash tools/rebrand.sh --package "$(PACKAGE)" $(if $(NAME),--name "$(NAME)")

