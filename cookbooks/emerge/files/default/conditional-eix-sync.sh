#!/usr/bin/env bash

if [ /engineyard/portage/metadata/timestamp.chk -nt /var/cache/eix ]; then
  /usr/bin/eix-sync -u;
fi
