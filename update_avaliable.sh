#!/bin/bash

export PATH=/usr/local/bin/:/opt/homebrew/bin/:/usr/bin/:$PATH

function unset_languages(){
  # usage:
  # unset_languages array_to_search_in language

  array_to_search_in=("$@")                       # Get the full array (both arguments)
  ((last_idx=${#array_to_search_in[@]} - 1))      # Calculate the position of item_to_search
  item_to_search=${array_to_search_in[last_idx]}  # Set item_to_search
  unset array_to_search_in[last_idx]              # Remove item_to_search from the arrat

  ((last_idx=${#array_to_search_in[@]} - 1))      # Get the new last index
  first_idx=0

  while (( last_idx >= first_idx )); do
    
    middle=$(( (last_idx+first_idx)/2 ))
    
    if [[ "${array_to_search_in[$middle]}" > "$item_to_search" ]]; then
      last_idx=$(( middle-1 ))
    elif [[ "${array_to_search_in[$middle]}" < "$item_to_search" ]]; then
      first_idx=$(( middle+1 ))
    else
      cheat_list=( "${cheat_list[@]:0:$middle}" "${cheat_list[@]:$((middle+1))}" )
      break
    fi
  done

}

# Get the full list of avaliable cheats (sorted)
cheat_list=$(curl -s "cheat.sh/:list" | sort)

# Get only the languages avaliable
languages=$(echo "${cheat_list}" | grep ":learn" | awk -F'/' '{print $1}')

# Convert to arrays
cheat_list=( $cheat_list )
languages=( $languages )

# Removes the languages from the list
for i in "${!languages[@]}"; do
  unset_languages "${cheat_list[@]}" "${languages[$i]}"
done

# Converts the bash array to a json array (Removes special commands like :help and sublists like awk/*)
json_array=$(printf '%s\n' "${cheat_list[@]}" | grep -v ":\|/" | jq -R . | jq -s .)

# Format the output as Script Filter Json Format
# shellcheck disable=SC2016
jq -n --argjson item "$json_array" -f <(echo '{"items":[$item[] as $name | {"uid":$name,"title":$name,"arg":$name,"autocomplete":$name}]}')