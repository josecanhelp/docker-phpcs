ARG PHP
FROM php:8 as builder

# Install build dependencies
RUN set -eux \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		git \
	&& git clone https://github.com/squizlabs/PHP_CodeSniffer

ARG PHPCS
RUN set -eux \
	&& cd PHP_CodeSniffer \
	&& if [ "${PHPCS}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="$( git tag | grep -E "^v?${PHPCS}\.[.0-9]+\$" | sort -V | tail -1 )"; \
	fi \
	&& curl -sS -L https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${VERSION}/phpcs.phar -o /phpcs.phar \
	&& chmod +x /phpcs.phar \
	&& mv /phpcs.phar /usr/bin/phpcs


FROM php:${PHP} as production
LABEL \
	maintainer="Jose Soto <josecanhelp@gmail.com>" \
	repo="https://github.com/josecanhelp/docker-phpcs"

COPY --from=builder /usr/bin/phpcs /usr/bin/phpcs
ENV WORKDIR /data
WORKDIR /data

ENTRYPOINT ["phpcs"]
CMD ["--version"]
