#!/bin/bash

BASE_URL="https://apps-be.nesailab.com"


ACCESS_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/device" \
--header 'Content-Type: application/json' \
--data '{
    "deviceId": "12323",
    "platform": "ios",
    "appCode": "audio_note_1"
}' | jq ".data.accessToken")



curl --location 'https://apps-be.nesailab.com/api/app-audio-note/meetings' \
--header 'x-app-code: audio_note_1' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2OTVlMmE2NTQ3N2E5ZmU1ZTBjOWNhMzciLCJhcHBJZCI6IjY5NWUxZGFhNGNmY2FhMzMyNjIwY2Q2ZSIsImRldmljZUlkIjoiMTIzMjMiLCJpYXQiOjE3Njk0ODMyMTgsImV4cCI6MTc3MDA4ODAxOH0.ILKDhYGWZkLaXO0lMEtEl376IAdtCunMDUg34ZDMxi4' \
--data '{
    "title": ""
}'
