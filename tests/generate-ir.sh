yarn tsc

for i in ./tests/source?/pass/*.js; do
    node dist/index.js $i > "${i%.js}.ll"
done
