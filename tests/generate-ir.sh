yarn tsc

for i in ./tests/source?/pass/*.source; do
    node dist/index.js $i > $i.ir
done
