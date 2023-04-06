#!/bin/sh
apk update && apk add jq

ADMIN_EMAIL=${MB_ADMIN_EMAIL:-admin@metabase.local}
ADMIN_PASSWORD=${MB_ADMIN_PASSWORD:-Metapass123}

METABASE_HOST=${MB_HOSTNAME:-localhost}
METABASE_PORT=${MB_PORT:-3000}


# echo "⌚︎ Waiting for Metabase to start"
# while (! curl -s -m 5 http://${METABASE_HOST}:${METABASE_PORT}/api/session/properties -o /dev/null); do sleep 5; done

# echo "😎 Creating admin user"

SETUP_TOKEN_CURL="curl -s -m 5 -X GET \
    -H \"Content-Type: application/json\" \
    http://${METABASE_HOST}:${METABASE_PORT}/api/session/properties"
echo -e "${SETUP_TOKEN_CURL}"

SETUP_TOKEN=$(${SETUP_TOKEN_CURL} | jq -r '.["setup-token"]')
echo $SETUP_TOKEN

MB_TOKEN=$(curl -s -X POST \
    -H "Content-type: application/json" \
    -H "X-Metabase-Session: ${SETUP_TOKEN}" \
    http://${METABASE_HOST}:${METABASE_PORT}/api/setup \
    -d '{    
        "email": "${ADMIN_EMAIL}",
        "first_name": "Metabase",
        "last_name": "Admin",
        "password": "${ADMIN_PASSWORD}"    
}' | jq -r '.id')

echo $MB_TOKEN


# echo -e "\n👥 Creating some basic users: "
# curl -s "http://${METABASE_HOST}:${METABASE_PORT}/api/user" \
#     -H 'Content-Type: application/json' \
#     -H "X-Metabase-Session: ${MB_TOKEN}" \
#     -d '{"first_name":"Basic","last_name":"User","email":"basic@somewhere.com","login_attributes":{"region_filter":"WA"},"password":"'${ADMIN_PASSWORD}'"}'

# curl -s "http://${METABASE_HOST}:${METABASE_PORT}/api/user" \
#     -H 'Content-Type: application/json' \
#     -H "X-Metabase-Session: ${MB_TOKEN}" \
#     -d '{"first_name":"Basic 2","last_name":"User","email":"basic2@somewhere.com","login_attributes":{"region_filter":"CA"},"password":"'${ADMIN_PASSWORD}'"}'

# echo -e "\n👥 Basic users created!"

