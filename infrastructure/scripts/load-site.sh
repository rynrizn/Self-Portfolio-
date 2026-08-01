#!/usr/bin/env bash
set -uo pipefail

url="${1:-}"

if [[ ! "$url" =~ ^https://[A-Za-z0-9.-]+$ ]]; then
  printf 'usage: %s <cloudfront-url>\n' "$0" >&2
  exit 2
fi

paths=("/" "/index.html" "/css/site.css")
requests=0
successes=0
client_errors=0
server_errors=0
transport_errors=0

print_summary() {
  printf 'requests=%d 2xx=%d 4xx=%d 5xx=%d transport=%d\n' \
    "$requests" "$successes" "$client_errors" "$server_errors" "$transport_errors"
}

trap print_summary EXIT
trap 'exit 0' INT TERM

printf 'Generando tráfico para %s.\n' "$url"
printf 'Las solicitudes aparecerán en las métricas de CloudFront.\n'
printf 'Presiona Ctrl+C para detener el script y mostrar el resumen.\n\n'

while true; do
  requests=$((requests + 1))

  if (( RANDOM % 4 == 0 )); then
    path="/_load-test/missing-${RANDOM}-${requests}"
    request_kind="error intencional"
  else
    path="${paths[RANDOM % ${#paths[@]}]}"
    request_kind="contenido del sitio"
  fi

  status="$(
    curl --silent --show-error \
      --output /dev/null \
      --write-out '%{http_code}' \
      --connect-timeout 5 \
      --max-time 10 \
      --user-agent 'personal-site-load-test/1.0' \
      "${url}${path}"
  )" || status="000"

  case "$status" in
    2*) successes=$((successes + 1)); result="correcta" ;;
    4*) client_errors=$((client_errors + 1)); result="no encontrada" ;;
    5*) server_errors=$((server_errors + 1)); result="error del servidor" ;;
    *)  transport_errors=$((transport_errors + 1)); result="falló la conexión" ;;
  esac

  delay=$((RANDOM % 5 + 1))
  printf 'Solicitud %d (%s): GET %s -> %s (%s). Próxima solicitud en %d s.\n' \
    "$requests" "$request_kind" "$path" "$status" "$result" "$delay"
  sleep "$delay"
done
