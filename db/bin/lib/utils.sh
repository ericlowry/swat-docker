#!/usr/bin/env bash

#
# check_env - ensure all the required environment variables exist
#
function check_env() {
    if [[ -z "${COUCHDB_HOST}" ]]; then
        echo "ERROR: COUCHDB_HOST is not set"
        exit 1
    fi

    if [[ -z "${COUCHDB_USER}" ]]; then
        echo "ERROR: COUCHDB_USER is not set"
        exit 1
    fi

    if [[ -z "${COUCHDB_PASSWORD}" ]]; then
        echo "ERROR: COUCHDB_PASSWORD is not set"
        exit 1
    fi

    if [[ -z "${COUCHDB_DB_NAME}" ]]; then
        echo "ERROR: COUCHDB_DB_NAME is not set"
        exit 1
    fi

    if [[ -z "${COUCHDB_VIEW_NAME}" ]]; then
        echo "ERROR: COUCHDB_VIEW_NAME is not set"
        exit 1
    fi
}

#
# hash <password> - Hash a plaintext password into a bcrypt digest
#
function hash() {
    htpasswd -bnBC 12 "" "$1" | tr -d ':\n' | sed 's/$2y/$2a/'
}

#
# uuid - Grab a fresh UUID from the DB
#
function uuid() {
    curl -s ${COUCHDB_HOST}/_uuids | jq -r '.uuids[0]'
}

#
# timestamp - get the milliseconds since the epoch (similar to JavaScript)
#
function timestamp() {
    date +%s%n | cut -b1-13
}

#
# insert_doc - insert a document into the db, adding cdate, mdate, etc.
#
# usage:
#
# insert << EOF
# {
#     "_id":   "JUNK:`uuid`",
#     "type":  "JUNK",
# }
# EOF
#
function insert_doc() {
    cat /dev/stdin \
    |   jq --arg u admin --argjson ts `timestamp` \
            '. + {cdate: $ts, cuser: $u, mdate: $ts, muser: $u}' \
    |   curl \
            -X POST \
            ${COUCHDB_HOST}/${COUCHDB_DB_NAME} \
            --user ${COUCHDB_USER}:${COUCHDB_PASSWORD} \
            -H 'Content-Type: application/json' \
            --data-binary @-
}
