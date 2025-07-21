#!/bin/bash

docker exec -u root dst-server bash -c "
cd /dst-server/bin &&
./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master
"