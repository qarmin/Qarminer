#!/bin/bash
find . -name "*.gd" -exec sed -i 's/.empty()/.is_empty()/g' '{}' \;
find . -name "*.gd" -exec sed -i 's/method_data\[\"flags\"\]/method_data.get\(\"flags\"\)/g' '{}' \;
find . -name "*.gd" -exec sed -i 's/method_data\[\"args\"\]/method_data.get\(\"args\"\)/g' '{}' \;
find . -name "*.gd" -exec sed -i 's/method_data\[\"name\"\]/method_data.get\(\"name\"\)/g' '{}' \;
find . -name "*.gd" -exec sed -i 's/PoolStringArray/PackedStringArray/g' '{}' \;
find . -name "*.gd" -exec sed -i 's/arg\[\"class_name\"\]/arg.get\(\"class_name\"\)/g' '{}' \;
find . -name "*.gd" -exec sed -i 's/\[method_index\]\[\"name\"\]/[method_index].get\(\"name\"\)/g' '{}' \;