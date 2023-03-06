cd $(dirname $0)

function build() {
    npm install
}

function start() {
    npm run
}


if [ $1 = "build" ]
then
    build
elif [ $1 = "start" ]
then
    build
    start
fi