#!/usr/bin/env bash
set -euo pipefail

curl() {
  local url="${*: -1}"

  case "$url" in
    */_load-test/*) printf '404' ;;
    *)              printf '200' ;;
  esac
}

sleep() { [[ "$1" =~ ^[1-5]$ ]] || exit 1; kill -INT "$$"; }

export -f curl sleep

script="$(dirname "$0")/../scripts/load-site.sh"

missing_status=0
missing_output="$(bash "$script" 2>&1)" || missing_status=$?

[[ "$missing_status" -eq 2 ]]
[[ "$missing_output" == "usage: $script <cloudfront-url>" ]]

output="$(bash "$script" https://example.cloudfront.net)"

expected_intro=$'Generando tráfico para https://example.cloudfront.net.\nLas solicitudes aparecerán en las métricas de CloudFront.\nPresiona Ctrl+C para detener el script y mostrar el resumen.\n\n'
request_log="$(sed -n '5p' <<< "$output")"
summary="${output##*$'\n'}"

[[ "$output" == "$expected_intro"* ]]
[[ "$request_log" =~ ^Solicitud\ 1\ \((contenido\ del\ sitio|error\ intencional)\):\ GET\ /.*\ -\>\ (200|404)\ \((correcta|no\ encontrada)\)\.\ Próxima\ solicitud\ en\ [1-5]\ s\.$ ]]
[[ "$summary" =~ ^requests=1\ 2xx=([0-9]+)\ 4xx=([0-9]+)\ 5xx=0\ transport=0$ ]]
(( BASH_REMATCH[1] + BASH_REMATCH[2] == 1 ))
