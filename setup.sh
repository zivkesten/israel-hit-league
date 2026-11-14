P=israel-hit-league
cd ~/israel-hit-league
gcloud services enable firebasedatabase.googleapis.com firebasehosting.googleapis.com --project $P
curl -s -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" -d '{}' "https://firebasedatabase.googleapis.com/v1beta/projects/$P/locations/us-central1/instances?databaseId=$P-default-rtdb" | head -c 300
echo; sleep 15
mkdir -p public && cp index.html admin.html public/
TOK=$(openssl rand -hex 6)
echo "$TOK" > ~/.hl_tok
firebase hosting:sites:create $P --project $P 2>&1 | tail -2
firebase deploy --only database,hosting --project $P --non-interactive 2>&1 | tail -10
printf '"%s"' "$TOK" | firebase database:set /secret --project $P --force 2>&1 | tail -2
DB=https://$P-default-rtdb.firebaseio.com
echo "no-token write:"; curl -s -X PATCH -d '{"live/on":true}' $DB/.json
N=t$RANDOM
echo; echo "token write:"; curl -s -X PATCH -d "{\"live/on\":false,\"liveN\":\"$N\",\"liveK\":\"$TOK$N\"}" $DB/.json
echo; curl -s $DB/live.json; echo; curl -s $DB/secret.json; echo
echo TOKEN:$TOK
