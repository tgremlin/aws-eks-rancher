#!/bin/bash

curl -Lo ./terraform-docs.tar.gz \
https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
./terraform-docs --config .tfdocs-config.yml .