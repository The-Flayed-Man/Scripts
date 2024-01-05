#!/bin/bash

# Function to ask user for new alias
ask_for_alias() {
    read -p "Enter the alias name: " alias_name
    read -p "Enter the command for the alias: " command
    echo "alias $alias_name='$command'"
}

# Array to hold aliases
declare -a aliases

# Loop to collect aliases
while true; do
    # Ask for an alias
    new_alias=$(ask_for_alias)
    
    # Add to the array
    aliases+=("$new_alias")
    
    # Ask if user wants to add another
    read -p "Do you want to add another alias? (y/n) " answer
    if [ "$answer" != "y" ]; then
        break
    fi
done

# Display the aliases and ask for confirmation
echo "You have added the following aliases:"
printf "%s\n" "${aliases[@]}"
read -p "Are you sure you want to add these to .bashrc? (y/n) " confirm

if [ "$confirm" == "y" ]; then
    # Append the aliases to .bashrc and reload it
    for alias in "${aliases[@]}"; do
        echo "$alias" >> ~/.bashrc
    done
    source ~/.bashrc
    echo "Aliases added and .bashrc reloaded."
else
    echo "No aliases were added."
fi