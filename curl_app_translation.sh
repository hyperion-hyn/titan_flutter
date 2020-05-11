#!/usr/bin/env bash
curl -c ./.trans_cookies.txt -d 'username=admin&password=elsRON7wY6aaYH4H' http://t.maprich.net/admin/signin;

#for language in zh_CN zh_HK en ko ; do
for language in zh_CN ; do
    curl -b ./.trans_cookies.txt http://t.maprich.net/admin/translation/export?lang=$language \
    | jq '.' > ./res/values/strings_$language.arb;
done
