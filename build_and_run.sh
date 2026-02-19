#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Парсинг флагов
BUILD_MODE="debug"
RUST_FLAG=""
RUST_BINARY_PATH="rust_app/target/debug/rust_app"

if [ "$1" == "release" ]; then
  BUILD_MODE="release"
  RUST_FLAG="--release"
  RUST_BINARY_PATH="rust_app/target/release/rust_app"
fi

echo -e "${GREEN}Режим сборки: ${YELLOW}${BUILD_MODE}${NC}"
echo -e "${GREEN}Начинаем сборку проектов...${NC}"

# 1. Собираем Rust
echo "Сборка Rust приложения ($BUILD_MODE)..."
cd rust_app || exit
cargo build $RUST_FLAG
cd ..
cp "$RUST_BINARY_PATH" ./rust_app_bench

# 2. Собираем Go
echo "Сборка Go приложения..."
cd go_app || exit
# Go обычно не требует флага release так, как Rust
go build -o ../go_app_bench main.go
cd ..

echo -e "${GREEN}Сборка завершена. Запуск бенчмарка...${NC}"

# 3. Запуск Hyperfine
# Флаг -N отключает использование shell для более точных замеров
hyperfine -N \
  "./rust_app_bench" \
  "./go_app_bench" \
  --export-markdown results.md

echo -e "${GREEN}Готово! Результаты сохранены в results.md${NC}"