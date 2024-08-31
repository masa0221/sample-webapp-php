#!/usr/bin/env bash

# コマンドが存在するかチェックする関数
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: '$1' command not found. Please install it.${NC}"
        exit 1
    fi
}

# ANSIカラーコード
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# コマンドの存在をチェック
commands=("curl" "awk" "sed" "grep")
for cmd in "${commands[@]}"; do
    check_command "$cmd"
done

# グローバル変数でテスト結果をトラッキング
test_failed=0
total_tests=0
failed_tests=0
passed_tests=0

# HTTPリクエストを実行し、レスポンスをチェックする関数
test_endpoint() {
    local url=$1
    local expected_status=$2
    shift 2
    local expected_strings=("$@")

    total_tests=$((total_tests + 1))

    # HTTPリクエストを実行し、ステータスコードとレスポンスボディを取得
    response=$(curl -s -w "\n%{http_code}" "${url}")
    status_code=$(echo "${response}" | awk 'END{print}')
    body=$(echo "${response}" | sed '$d')

    # ステータスコードをチェック
    if [ "${status_code}" -ne "${expected_status}" ]; then
        echo -e "${RED}x Test failed: Expected status code ${expected_status}, got ${status_code}${NC}"
        test_failed=1
        failed_tests=$((failed_tests + 1))
    else
        echo -e "${GREEN}✔ Status code test passed${NC}"
    fi

    # レスポンスボディにすべての期待される文字列が含まれているかチェック
    for expected_string in "${expected_strings[@]}"; do
        if ! echo "${body}" | grep -q "${expected_string}"; then
            echo -e "${RED}x Test failed: Expected string '${expected_string}' not found in response body${NC}"
            echo -e "${RED}Actual response body:${NC}\n${body}"
            test_failed=1
            failed_tests=$((failed_tests + 1))
        else
            echo -e "${GREEN}✔ String '${expected_string}' found in response body${NC}"
        fi
    done

    if [ "${test_failed}" -eq 0 ]; then
        passed_tests=$((passed_tests + 1))
    fi
}

# テスト実行
test_endpoint "http://localhost:8080" 200 \
  "Hello!" \
  'PHP version: .*8.3.*' \
  'MySQL version: .*8.0.*'


# テスト結果に基づくサマリーのメッセージを表示
if [ "${failed_tests}" -ne 0 ]; then
    echo -e "${RED}--- Test Summary ---${NC}"
    echo -e "${RED}Failed tests: ${failed_tests} of ${total_tests}${NC}"
    exit 1
else
    echo -e "${GREEN}--- Test Summary ---${NC}"
    echo -e "${GREEN}All ${total_tests} tests passed.${NC}"
    exit 0
fi

