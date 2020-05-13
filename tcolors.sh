#!/usr/bin/env bash

fail_color=$'\033[31;1m'
color_end=$'\033[0m'
function="foo"
line_number="42"

printf "%sError - Function: %s, Line: %d%s\n" "$fail_color" "$function" "$line_number" "$color_end"