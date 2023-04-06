#!/bin/sh

if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    apk update && apk add jq
fi

ADMIN_EMAIL=${MB_ADMIN_EMAIL:-admin@metabase.local}
ADMIN_PASSWORD=${MB_ADMIN_PASSWORD:-Metapass123}

METABASE_HOST=${MB_HOSTNAME:-localhost}
METABASE_PORT=${MB_PORT:-3000}

# echo "⌚︎ Waiting for Metabase to start"
while (! curl -s -m 5 http://${METABASE_HOST}:${METABASE_PORT}/api/session/properties -o /dev/null); do sleep 5; done

# echo "😎 Creating BQ connection"

# Authenticate to API
MB_TOKEN_CURL=$(cat <<EOF
curl -s -X POST \
    -H "Content-type: application/json" \
    http://${METABASE_HOST}:${METABASE_PORT}/api/session \
    -d '{    
        "username": "${ADMIN_EMAIL}",
        "password": "${ADMIN_PASSWORD}"    
}'
EOF
)

MB_TOKEN=$(eval $MB_TOKEN_CURL | jq -r '.id')
echo $MB_TOKEN
# END Authenticate to API

# Find database ID, exit if not found
DATABASEID_CURL=$(cat <<EOF
curl -s -X GET \
    -H "Content-type: application/json" \
    -H "X-Metabase-Session: ${MB_TOKEN}" \
    http://${METABASE_HOST}:${METABASE_PORT}/api/database
EOF
)

APIDATABASEID=$(eval $DATABASEID_CURL | jq '.data[] | select(.name | contains("Beer Reviews"))| .id')
#echo "Get Database Results: ${DATABASEID_CURL}"

if [[ -z ${APIDATABASEID} ]]
then
    echo "REVIEWS DATABASE WAS NOT FOUND: Please confirm that the connection exists in the UI and is still named \"Beer Reviews\""
    echo "Exiting ..."
    exit
else 
    echo "Reviews Database ID: ${APIDATABASEID}"  
fi

# API Call to update BQ Database connection with proper GCP credentials
# (Alternative to using UI)
update_database_curl=$(cat <<EOF
curl 'http://localhost:3000/api/database/${APIDATABASEID}' \
  -X 'PUT' \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "X-Metabase-Session: ${MB_TOKEN}" \
  --data-raw '{
    "is_on_demand": false,
    "is_full_sync": false,
    "is_sample": false,
    "cache_ttl": null,
    "refingerprint": false,
    "auto_run_queries": true,
    "schedules": {},
    "details": {
      "project-id": null,
      "service-account-json": $(cat $GOOGLE_APPLICATION_CREDENTIALS | jq -Rsa),
      "dataset-filters-type": "inclusion",
      "dataset-filters-patterns": "my_beer_review_dataset",
      "advanced-options": false
    },
    "name": "Beer Reviews",
    "engine": "bigquery-cloud-sdk"
  }' \
  --compressed
EOF
)
#echo "$update_database_curl"

eval $update_database_curl | jq