#!/bin/bash

export PATH=/usr/local/bin/:/opt/homebrew/bin/:/usr/bin/:$PATH

result=$(curl -s "cheat.sh/${search_for}?qT")
previous_line=""
json_array=""
command_buffer=""

SAVEIFS=$IFS        # Save current IFS (Internal Field Separator)
IFS=$'\n'           # Change IFS to newline char

for line in $result; do

  # Escape chars like double quotes
  line="${line//\"/\\\"}"

  # Check if the line is a comment
  if [[ "${line:0:1}" == '#' ]]; then

    # It whe have commands on buffer
    if [[ -n "${command_buffer}" ]]; then
      # output to json array
      new_element="{\"title\":\"${previous_line:2}\",\"subtitle\":\"${command_buffer:0:50}\",\"arg\":\"$command_buffer\",\"autocomplete\":\"$previous_line\"}"
      if [[ -z "${json_array}" ]]; then
        # Initialize the array
        json_array=$new_element
      else
        # Append to the end of the array
        json_array="${json_array},${new_element}"
      fi
    fi

    # clear command buffer
    command_buffer=""
    previous_line=$line

  else
    # Puts the line on the buffer
    if [[ -z "${command_buffer}" ]]; then
      command_buffer="${line}"
    else
      command_buffer="${command_buffer}\n${line}"
    fi

  fi

done

# It whe still have commands on buffer
if [[ -n "${command_buffer}" ]]; then
  # output to json array
  new_element="{\"title\":\"${previous_line:1}\",\"subtitle\":\"${command_buffer:0:50}\",\"arg\":\"$command_buffer\",\"autocomplete\":\"$previous_line\"}"
  if [[ -z "${json_array}" ]]; then
    # Initialize the array
    json_array=$new_element
  else
    # Append to the end of the array
    json_array="${json_array},${new_element}"
  fi
fi

# Append to the end of the array
json_array="{\"items\": [${json_array}]}"

echo "$json_array" | jq

IFS=$SAVEIFS        # Restore original IFS