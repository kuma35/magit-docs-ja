#!/bin/sh
find .. -type d -name locale -prune -o -type f -name "*.texi" -printf "po4a-gettextize --format texinfo --master %p --master-charset utf-8 --copyright-holder \"magit\" --package-name \"magit\" --package-version \"0.0\" --po ./ja/LC_MESSAGES/%f.po\n"
