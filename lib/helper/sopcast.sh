#
# Wrappr script for sp-sc auth - does two things:
#
# 1. Ensures that signals are handled correctly over the wire (orderly shutdown)
# 2. Feeds the HTTP output to the caller via stdout.
#

sp-sc-auth #{@url} 3908 #{@port} > /dev/null&
PID=$!

function cleanup {
    if [[ -n $(ps | awk '{print $1}' | grep $PID) ]]
    then
        kill -SIGKILL ${PID}
        wait ${PID} 2> /dev/null
    fi
}
trap cleanup SIGINT

CONNECTED=0
while [[ -n $(ps | awk '{print $1}' | grep ${PID}) && ${CONNECTED} -eq 0 ]]
do
    nc -z localhost #{@port}
    if [[ $? -eq 0 ]]
    then
        CONNECTED=1
    fi
done

if [[ CONNECTED -ne 1 ]]
then
    exit 1
fi

WAITING=1
while [[ ${WAITING} -eq 1 ]]
do
    curl http://localhost:#{@port}/ 2> /dev/null
    if [[ $? -ne 52 ]]
    then
        WAITING=0
    fi
done

cleanup
