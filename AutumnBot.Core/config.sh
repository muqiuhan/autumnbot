cd $(dirname $0)

function build() {
    dune build
}

function start() {
    ./_build/default/bin/core.exe
}

if [ $1 = "build" ]
then
    build
elif [ $1 = "start" ]
then
    build
    start
fi
