#!/bin/bash

BASE_URL="https://apps-be.nesailab.com"


ACCESS_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/device" \
--header 'Content-Type: application/json' \
--data '{
    "deviceId": "12323",
    "platform": "ios",
    "appCode": "audio_note_1"
}' | jq ".data.accessToken")



curl -s -X GET "$BASE_URL/api/app-audio-note/meetings" \
--header 'x-app-code: audio_note_1' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--data '{
    "title": ""
}'
