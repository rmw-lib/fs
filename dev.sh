#!/usr/bin/env bash
set -e
DIR=$( dirname $(realpath "$0") )
cd $DIR
if [ ! -n "$1" ] ;then
exe=test/index.coffee
else
exe=${@:1}
fi
exec npx nodemon --watch 'test/**/*' --watch 'src/**/*' -e coffee,js,mjs,json,wasm,txt,yaml --exec "rsync -av --include='*/' --include='*.js' --include='*.mjs' --exclude=* src/ lib/ && npx coffee -m --compile --output lib src/ && .direnv/bin/coffee $exe"

