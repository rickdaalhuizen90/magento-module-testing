#!/usr/bin/env bash

module_path=$1
name=$(jq -r '.name' "$module_path/composer.json" | sed 's/\//-/g')
version=$(jq -r '.version' "$module_path/composer.json")
zip_file="${name}-${version}.zip"

zip -r out/"$zip_file" "$module_path" -x "${module_path}/.git/*"

echo "\033[32mPackage: out/$zip_file\033[0m"
