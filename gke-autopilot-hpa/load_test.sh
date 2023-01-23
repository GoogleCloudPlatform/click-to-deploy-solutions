#!/bin/sh

max_requests=1000
host=$1

echo Load testing $host

while [[ $max_requests -ge $i ]];
do
curl http://${host}
let i=i+1
echo $i out of $max_requests...
done
