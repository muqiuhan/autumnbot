cd $(dirname $0)

function build() {
    xmake
}

function start() {
    xmake r
}


if [ $1 = "build" ]
then
    build
elif [ $1 = "start" ]
then
    build
    start
fi