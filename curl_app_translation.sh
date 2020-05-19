#!/usr/bin/env bash
curl -c ./.trans_cookies.txt -d 'username=admin&password=elsRON7wY6aaYH4H' http://t.maprich.net/admin/signin;


for language in "zh_CN" "zh_HK" "en" "ko" ; do
    curl -b ./.trans_cookies.txt http://t.maprich.net/admin/translation/export?lang=$language \
    | jq '.' > ./res/values/strings_$language.arb;


    if [ "$language" = "zh_CN" ];
    then
    replace "$language" "泰坦地图" "导入钱包";
        cat ./res/values/strings_$language.arb | \
        jq 'to_entries |
            map(if .key == "app_name"
                then . + {"value":"泰坦地图"}
                elif .key == "import_account"
                then . + {"value":"导入钱包"}
                else .
                end
             ) |
            from_entries' > ./res/values/new.arb;
        cat ./res/values/new.arb > ./res/values/strings_$language.arb;
        rm -f ./res/values/new.arb;

    elif [ "$language" = "zh_HK" ];
    then
        cat ./res/values/strings_$language.arb | \
        jq 'to_entries |
            map(if .key == "app_name"
                then . + {"value":"泰坦地圖"}
                elif .key == "import_account"
                then . + {"value":"導入钱包"}
                else .
                end
             ) |
            from_entries' > ./res/values/new.arb;
        cat ./res/values/new.arb > ./res/values/strings_$language.arb;
        rm -f ./res/values/new.arb;
    elif [ "$language" = "en" ];
    then
        cat ./res/values/strings_$language.arb | \
        jq 'to_entries |
            map(if .key == "app_name"
                then . + {"value":"Titan"}
                elif .key == "import_account"
                then . + {"value":"Import Account"}
                else .
                end
             ) |
            from_entries' > ./res/values/new.arb;
        cat ./res/values/new.arb > ./res/values/strings_$language.arb;
        rm -f ./res/values/new.arb;
    elif [ "$language" = "ko" ];
    then
        cat ./res/values/strings_$language.arb | \
        jq 'to_entries |
            map(if .key == "app_name"
                then . + {"value":"타이탄"}
                elif .key == "import_account"
                then . + {"value":"지갑 가져오기"}
                else .
                end
             ) |
            from_entries' > ./res/values/new.arb;
        cat ./res/values/new.arb > ./res/values/strings_$language.arb;
        rm -f ./res/values/new.arb;
    else
    echo '翻译下载完成'
    fi

done
rm -f ./.trans_cookies.txt