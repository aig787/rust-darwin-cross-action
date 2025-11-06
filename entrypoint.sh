#!/bin/bash

set -e

# Parse and export environment variables (4th argument)
if [ "x$4" != "x" ]; then
    echo "Setting environment variables from input"
    # Handle newline-separated KEY=VALUE format
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        # Export the variable
        export "$line"
        # Extract just the key name for logging (before the = sign)
        key="${line%%=*}"
        echo "Exported: $key"
    done <<< "$4"
fi

if [ "x$3" != "x" ]; then
    echo $3 > .git_credentials
    git config --global credential.helper "store --file $PWD/.git_credentials"
    git config --global "url.https://github.com/.insteadOf" "ssh://git@github.com/"
    git config --global --add "url.https://github.com/.insteadOf" "git@github.com:"
fi

echo "Setting up local Cargo env"
mkdir -p .cargo
ln -sf $CARGO_HOME/bin .cargo/

if [ -f .cargo/config ]; then
    mv .cargo/config .cargo/config.original
    cp $CARGO_HOME/config .cargo/config
    cat .cargo/config.original >> .cargo/config
else 
    cp $CARGO_HOME/config .cargo/config
fi


if [ "x$2" != "x" ]; then
    (cd $2 && $CARGO_HOME/bin/cargo $1)
else 
    $CARGO_HOME/bin/cargo $1
fi
