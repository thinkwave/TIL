#!/usr/bin/env sh

# 오류 발생시 중단한다.
set -e

# 문서(md)를 build하여 html로 만든다. 
yarn build

# build가 output된 폴더로 이동한다. 
cd public

git clone https://github.com/thinkwave/thinkwave.github.io
cp -rf thinkwave.github.io/.git ./.git
rm -rf thinkwave.github.io

git config --global http.postBuffer 524288000

git add .

git commit -m 'deploy!!!'

git push 

cd -