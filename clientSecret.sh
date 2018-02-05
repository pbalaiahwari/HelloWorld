#!/usr/bin/env bash

source logiconfig.sh

if [[ -d "$NODE_HOME" ]]; then
   export PATH="$NODE_HOME/bin":$PATH
fi

if [ ! -f "$NODE_HOME/bin/node" ];
then
    echo "The NODE_HOME environment variable is not defined correctly"
    echo "It is needed to run Logi Application Services."
    exit 1
fi



[ -z "$LOGI_HOME" ] && echo "LOGI_HOME must be set. Exiting" && exit 1;
[ ! -d "$LOGI_HOME" ] && echo "LOGI_HOME points to invalid location. Exiting" && exit 1;

# run the App Service

cd "$LOGI_HOME/platform/bin"
node clientSecret.js $@


exit $?