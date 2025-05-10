#!/bin/bash

# Path to your text file
APPEND_FILE="bashrc_append.txt"

# Path to your home directory's .bashrc
BASHRC_FILE="$HOME/.bashrc"

# Append the contents
if [ -f "$APPEND_FILE" ]; then
    cat "$APPEND_FILE" >> "$BASHRC_FILE"
    echo "Appended contents of $APPEND_FILE to $BASHRC_FILE"
else
    echo "Error: $APPEND_FILE not found."
    exit 1
fi

