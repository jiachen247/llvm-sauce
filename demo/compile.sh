cd ..
# tsc
name=$(echo $1 | cut -f 1 -d '.')
yarn start --tco demo/$1 -o demo/$name.ll
llc demo/$name.ll -O3 -o demo/$name.s
g++ --std=c++11 -no-pie demo/$name.s -o demo/$name