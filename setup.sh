P=israel-hit-league
cd ~/israel-hit-league
T=$(gcloud auth print-access-token)
U=https://firebasedatabase.googleapis.com/v1beta/projects/$P/locations/us-central1/instances
curl -s -X POST -H "Authorization: Bearer $T" -H "x-goog-user-project: $P" -H "Content-Type: application/json" -d '{}' "$U?databaseId=$P-default-rtdb" | head -c 400
echo; sleep 20
curl -s -H "Authorization: Bearer $T" -H "x-goog-user-project: $P" "$U" | head -c 400
echo
mkdir -p public && cp index.html admin.html public/
[ -f ~/.hl_tok ] || openssl rand -hex 6 > ~/.hl_tok
TOK=$(cat ~/.hl_tok)
firebase hosting:sites:create $P --project $P 2>&1 | tail -2
firebase deploy --only database,hosting --project $P --non-interactive 2>&1 | tail -10
printf '"%s"' "$TOK" | firebase database:set /secret --project $P --force 2>&1 | tail -2
DB=https://$P-default-rtdb.firebaseio.com
echo "no-token write:"; curl -s -X PATCH -d '{"live/on":true}' $DB/.json
N=t$RANDOM
echo; echo "token write:"; curl -s -X PATCH -d "{\"live/on\":false,\"liveN\":\"$N\",\"liveK\":\"$TOK$N\"}" $DB/.json
echo; curl -s $DB/live.json; echo; curl -s $DB/secret.json; echo
echo TOKEN:$TOK
echo FINISHED
