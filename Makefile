build:
	mkdir -p bin
	docker build \
		-t matthewbaggett/static:php-cs-fixer \
		--progress plain \
		--build-arg PHP_EXTENSIONS="filter,tokenizer,dom,mbstring,phar" \
		--build-arg PHAR_DOWNLOAD_URL="https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/v3.49.0/php-cs-fixer.phar" \
		--build-arg OUTPUT_BIN_NAME="php-cs-fixer" \
		.
	docker cp $$(docker create --name static-php-cs-fixer matthewbaggett/static:php-cs-fixer):/build/bin/php-cs-fixer bin/. && \
	docker rm -v static-php-cs-fixer
	bin/php-cs-fixer --version
