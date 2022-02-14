#!/bin/bash

export PATH=/usr/local/bin/:/opt/homebrew/bin/:/usr/bin/:$PATH

# Get the full list of avaliable cheats
cheat_list=$(curl -s "cheat.sh/:list")

SAVEIFS=$IFS        # Save current IFS (Internal Field Separator)
IFS=$'\n'           # Change IFS to newline char
array=($cheat_list) # split the `names` string into an array by the same name
IFS=$SAVEIFS        # Restore original IFS

# Converts the bash array to a json array
json_array=$(printf '%s\n' "${array[@]}" | jq -R . | jq -s .)

# Format the output as Script Filter Json Format
jq -n --argjson item "$json_array" -f <(echo '{"items":[$item[] as $name | {"uid":$name,"title":$name,"arg":$name,"autocomplete":$name}]}')