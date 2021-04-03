yarn tsc
tested=0
passed=0

function report() {
    echo "Passed $passed/$tested tests!"
    echo ""
    exit
}

trap report INT

for i in ./tests/source?/*/*.js; do
    echo "Testing $i"
    tested=$((tested+1))
    expected=$(cat $i | awk 'BEGIN{expected=0}/\/\/ *expected: */{expected = 1}//{if(expected){print $0}}' $1 \
        | sed -e 's/\/\/ expected: *\(.*\)/\1/') # expected output
    tmp=$(mktemp)
    yarn node dist/index.js --tco $i -o $tmp &> /dev/null
    output=$(lli $tmp)
    if [ "$expected" != "$output" ]; then
        >&2 echo "Unexpected output in test $i"
        >&2 echo "OUT > $output"
        >&2 echo "EXP < $expected"
    else
        passed=$((passed+1))
    fi
    rm $tmp
done

report
# find ./tests/ -name "test*.js" | xargs -l yarn node dist/index.js