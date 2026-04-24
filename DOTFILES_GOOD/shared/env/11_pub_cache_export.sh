#!/bin/sh
# Extrait partiel de shared/env.sh — export PUB_CACHE seul (pas de mkdir ici ; le bac à sable reste minimal).

export PUB_CACHE="${HOME:-}/.pub-cache"
