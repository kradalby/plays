#!/bin/bash
set -euxo pipefail

rm -f /etc/caddy/Caddyfile.json.d/*.json

/usr/bin/caddy adapt --config /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.json.d/Caddyfile.json

for yaml_file in /etc/caddy/Caddyfile.yaml.d/*
do
    filename=`basename $yaml_file`
    /usr/bin/caddy adapt --adapter yaml --config "$yaml_file" > "/etc/caddy/Caddyfile.json.d/$filename.json"
done

# /usr/bin/jq -s 'reduce .[] as $item ({}; . * $item)' /etc/caddy/Caddyfile.json.d/* > /etc/caddy/Caddyfile.json
/usr/bin/jq -s 'def deepmerge(a;b):
  reduce b[] as $item (a;
    reduce ($item | keys_unsorted[]) as $key (.;
      $item[$key] as $val | ($val | type) as $type | .[$key] = if ($type == "object") then
        deepmerge({}; [if .[$key] == null then {} else .[$key] end, $val])
      elif ($type == "array") then
        (.[$key] + $val | unique)
      else
        $val
      end)
    );
  deepmerge({}; .)' /etc/caddy/Caddyfile.json.d/* > /etc/caddy/Caddyfile.json
