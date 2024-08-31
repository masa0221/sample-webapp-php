#!/usr/bin/env bash

set -e

cd "$(dirname $0)"/../

docker compose exec app sh -c 'find /var/www/html -name "*php" | xargs php -l'

