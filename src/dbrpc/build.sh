#!/usr/bin/env bash
set -eu

gcloud builds submit --tag gcr.io/ramaro-dev/aaaas-dbrpc:${VERSION}
