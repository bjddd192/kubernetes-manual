#! /bin/bash

# 编译构建 gitbook
gitbook install
gitbook build
# 查远程分支
# git branch -r
# 删除本地 gh-pages 分支
git branch -D gh-pages
# 删除远端的 gh-pages 分支
git branch -r -d origin/gh-pages
git push origin :gh-pages
# 创建新的 gh-pages 分支
git checkout --orphan gh-pages
# 发布文件，整理与推送
git rm -f --cached -r .
sleep 5
git clean -df
sleep 5
# rm -rf *~
# echo "*~" > .gitignore
echo "_book" >> .gitignore
echo "node_modules" >> .gitignore
git add .gitignore
git commit -m "Ignore some files"
cp -r _book/* .
git add .
git commit -m "Publish book"
# 推送 gh-pages 分支
git push -u origin gh-pages
# 切回 master 分支
git checkout master
