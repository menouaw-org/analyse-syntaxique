#!/usr/bin/env bash

show_help() {
  printf "%s\n" "Usage: $0 <fichier_log> [error|notice|all]"
}

print_record() {
  local timestamp="$1"
  local type="$2"
  local message="$3"

  printf "%s | %s | %s\n" "$timestamp" "$type" "$message"
}

parse_line() {
  local line="$1"
  local filter_type="$2"

#  echo "LINE=${line}"
#  echo "FILTER=${filter_type}"

#  <extraire le timestamp, le type et le message>
#  [timestamp] [type] message
  local pattern="^\[([^]]+)\][[:space:]]\[(error|notice)\][[:space:]](.*)"
  if [[ "$line" =~ $pattern ]]; then
    local timestamp="${BASH_REMATCH[1]}"
    local type="${BASH_REMATCH[2]}"
    local message="${BASH_REMATCH[3]}"

#    echo "TIMESTAMP=${timestamp}"
#    echo "TYPE=${type}"
#    echo "MESSAGE=${message}"
  else
#    echo "NO MATCH: ${line}"
    return 0
  fi

#  <appliquer le filtrage>
  if [[ "$filter_type" == "all" || "$filter_type" == "$type" ]]; then
#      <appeler print_record si la ligne doit être affichée>
    print_record "$timestamp" "$type" "$message"
  fi
}

parse_log_file() {
  local log_file="$1"
  local filter_type="$2"

  while read -r line; do
    parse_line "$line" "$filter_type"
  done < "$log_file"
}

main() {
  local log_file="${1:-}"
  local filter_type="${2:-all}"

#  <vérifier les paramètres minimaux>
#  <vérifier que le fichier existe et est lisible>
  parse_log_file "$log_file" "$filter_type"
}

#parse_line "[Sun Dec 04 04:47:44 2005] [notice] workerEnv.init() ok /etc/httpd/conf/workers2.properties" "all"
#parse_line "[Sun Dec 04 04:47:44 2005] [notice] workerEnv.init() ok /etc/httpd/conf/workers2.properties" "notice"
#parse_line "[Sun Dec 04 04:47:44 2005] [notice] workerEnv.init() ok /etc/httpd/conf/workers2.properties" "error"
#parse_line "[Sun Dec 04 04:47:44 2005] [error] mod_jk child workerEnv in error state 6" "error"

main "$@"