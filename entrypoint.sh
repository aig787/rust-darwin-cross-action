#!/bin/bash

set -e

# Parse and export environment variables (4th argument)
if [ "x$4" != "x" ]; then
    # Handle newline-separated KEY=VALUE format
    echo "DEBUG: Received env input (length: ${#4})"
    echo "DEBUG: Processing environment variables..."
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        # Extract variable name for logging (before = sign)
        var_name="${line%%=*}"
        echo "DEBUG: Exporting variable: $var_name"
        # Use eval to properly interpret quotes in the value
        eval export "$line"
        # Verify it was set (only log length for security)
        eval "value=\${$var_name}"
        echo "DEBUG: Variable $var_name is now set (value length: ${#value})"
    done <<< "$4"
    echo "DEBUG: Finished processing environment variables"
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

if [ -f .cargo/config.toml ]; then
    mv .cargo/config.toml .cargo/config.toml.original
    cp $CARGO_HOME/config .cargo/config.toml
    cat .cargo/config.toml.original >> .cargo/config.toml
elif [ -f .cargo/config ]; then
    cp $CARGO_HOME/config .cargo/config.toml
    cat .cargo/config >> .cargo/config.toml
else
    cp $CARGO_HOME/config .cargo/config.toml
fi


echo "DEBUG: About to run cargo"
if [ -n "$CARGO_REGISTRIES_SEVINCIT_CARGO_DEFAULT_TOKEN" ]; then
    echo "DEBUG: CARGO_REGISTRIES_SEVINCIT_CARGO_DEFAULT_TOKEN is set (length: ${#CARGO_REGISTRIES_SEVINCIT_CARGO_DEFAULT_TOKEN})"
else
    echo "DEBUG: CARGO_REGISTRIES_SEVINCIT_CARGO_DEFAULT_TOKEN is NOT set"
fi

if [ "x$2" != "x" ]; then
    (cd $2 && $CARGO_HOME/bin/cargo $1)
else
    $CARGO_HOME/bin/cargo $1
fi
