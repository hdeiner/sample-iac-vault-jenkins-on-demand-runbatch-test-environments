#!/bin/bash

rm -rf ./vault/UnsealKey1 ./vault/UnsealKey2 ./vault/UnsealKey3 ./vault/UnsealKey4 ./vault/UnsealKey5 ./vault/InitialRootToken

while read line
do
    echo "$line" | grep  "Unseal Key [0-9]\: \(\.*\)" | cut -d: -f2 | xargs > ./.temp
    if [ $(wc -c < ./.temp) -ge 8 ]; then
        if [ ! -f "./vault/UnsealKey1" ]; then
            cp ./.temp ./vault/UnsealKey1
        else
            if [ ! -f "./vault/UnsealKey2" ]; then
                cp ./.temp ./vault/UnsealKey2
            else
                if [ ! -f "./vault/UnsealKey3" ]; then
                    cp ./.temp ./vault/UnsealKey3
                else
                    if [ ! -f "./vault/UnsealKey4" ]; then
                        cp ./.temp ./vault/UnsealKey4
                    else
                        if [ ! -f "./vault/UnsealKey5" ]; then
                            cp ./.temp ./vault/UnsealKey5
                        fi
                    fi
                fi
             fi
        fi
        rm ./.temp
    fi
done < vault.initialization.out
rm ./.temp

while read line
do
    echo "$line" | grep  "Initial Root Token\: \(\.*\)" | cut -d: -f2 | xargs > ./.temp
    if [ $(wc -c < ./.temp) -ge 8 ]; then
        cp ./.temp ./vault/InitialRootToken
        rm ./.temp
    fi
done < vault.initialization.out
rm ./.temp