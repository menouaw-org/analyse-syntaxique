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

csv_escape() {
  local value="$1"

  value="${value//\"/\"\"}"

  printf '"%s"' "$value"
}

print_csv_header() {
  printf "%s\n" "timestamp;type;message;is_forbidden;client_ip"
}

print_csv_record() {
  local timestamp="$1"
  local type="$2"
  local message="$3"
  local is_forbidden="$4"
  local client_ip="$5"

  csv_escape "$timestamp"
  printf ";"
  csv_escape "$type"
  printf ";"
  csv_escape "$message"
  printf ";"
  csv_escape "$is_forbidden"
  printf ";"
  csv_escape "$client_ip"
  printf "\n"
}

parse_line() {
  local line="$1"
  local filter_type="$2"

  local parsing_pattern="^\[([^]]+)\][[:space:]]\[(error|notice)\][[:space:]](.*)"
  local forbidden_message="Directory index forbidden by rule"
  local ip_pattern="\[client[[:space:]]([^]]+)\]"
  local is_forbidden="no"
  local client_ip=""

#  echo "LINE=${line}"
#  echo "FILTER=${filter_type}"

#  <extraire le timestamp, le type et le message>
#  [timestamp] [type] message

  if [[ "$line" =~ $parsing_pattern ]]; then
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

    # [Sun Dec 04 05:15:09 2005] [error] [client 222.166.160.184] Directory index forbidden by rule: /var/www/html/
    if [[ "$message" == *"$forbidden_message"* ]]; then
      is_forbidden="yes"

      if [[ "$message" =~ $ip_pattern ]]; then
        client_ip="${BASH_REMATCH[1]}"
      fi
    fi

#      <appeler print_record si la ligne doit être affichée>
#      print_record "$timestamp" "$type" "$message"
      print_csv_record "$timestamp" "$type" "$message" "$is_forbidden" "$client_ip"
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
  print_csv_header
  parse_log_file "$log_file" "$filter_type"
}

# analyse syntaxique
#parse_line "[Sun Dec 04 04:47:44 2005] [notice] workerEnv.init() ok /etc/httpd/conf/workers2.properties" "all"
#parse_line "[Sun Dec 04 04:47:44 2005] [notice] workerEnv.init() ok /etc/httpd/conf/workers2.properties" "notice"
#parse_line "[Sun Dec 04 04:47:44 2005] [notice] workerEnv.init() ok /etc/httpd/conf/workers2.properties" "error"
#parse_line "[Sun Dec 04 04:47:44 2005] [error] mod_jk child workerEnv in error state 6" "error"
#parse_line "[Sun Dec 04 05:15:09 2005] [error] [client 222.166.160.184] Directory index forbidden by rule: /var/www/html/" "all"

# csv
#csv_escape 'message simple'
#printf "\n"
#csv_escape 'message avec ; point-virgule'
#printf "\n"
#csv_escape 'message avec "guillemets"'
#printf "\n"

main "$@"