# datera-get-rest.sh

This Script requires jq from  https://stedolan.github.io/jq/

This is a simple UNIX Shell script to login to Datera Rest API and get the json output of an endpoint

To install:

wget https://raw.githubusercontent.com/heikowuest/datera-get-rest.sh/master/datera-get-rest.sh
chmod 700 datera-get-rest.sh

./datera-get-rest.sh -u admin -p password -h $mgmtvip storage_nodes

where mgmtvip is the management vip of the cluster
