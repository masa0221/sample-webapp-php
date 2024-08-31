#!/usr/bin/env bash

cd "$(dirname "$0")"

ECR_HOST="123456789012.dkr.ecr.ap-northeast-1.amazonaws.com"
TAG="latest"
PUSH=false
PLATFORM=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -t|--tag)
      TAG="$2"
      shift 2
      ;;
    -h|--host)
      ECR_HOST="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    *)
      echo "Invalid option: $1" >&2
      exit 1
      ;;
  esac
done

# 使用中のマシンのプラットフォームを自動検出
if [ -z "${PLATFORM}" ]; then
  PLATFORM=$(uname -m)
  case "${PLATFORM}" in
    x86_64)
      PLATFORM="linux/amd64"
      ;;
    aarch64)
      PLATFORM="linux/arm64"
      ;;
    *)
      echo "Unsupported platform: ${PLATFORM}" >&2
      exit 1
      ;;
  esac
fi

docker build . \
  --file ./docker/nginx/Dockerfile \
  --tag "webapp-nginx:${TAG}" \
  --platform "${PLATFORM}"

docker build . \
  --file ./docker/php-fpm/Dockerfile \
  --tag "webapp-php:${TAG}" \
  --platform "${PLATFORM}"

if [ -n "${ECR_HOST}" ]; then
  ECR_NGINX_TAG="${ECR_HOST}/webapp-nginx:${TAG}"
  ECR_PHP_TAG="${ECR_HOST}/webapp-php:${TAG}"
  docker tag "webapp-nginx:${TAG}" "${ECR_NGINX_TAG}"
  docker tag "webapp-php:${TAG}" "${ECR_PHP_TAG}"

  if [ "${PUSH}" = true ]; then
    docker push "${ECR_NGINX_TAG}"
    docker push "${ECR_PHP_TAG}"
  fi
fi

