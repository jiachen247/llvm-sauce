yarn tsc
find ./tests/ -name "test*.js" | xargs -l yarn node dist/index.js
