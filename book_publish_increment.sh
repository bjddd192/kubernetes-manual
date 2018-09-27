#! /bin/bash

# 显示错误并退出
# SHELL中的 exit 1 和 exit 1 有什么区别？
# exit 1 可以告知你的程序的使用者：你的程序是正常结束的。
# 如果 exit 非 0 值，那么你的程序的使用者通常会认为你的程序产生了一个错误。
# 在 shell 中调用完你的程序之后，用 echo $? 命令就可以看到你的程序的 exit 值。
# 在 shell 脚本中，通常会根据上一个命令的 $? 值来进行一些流程控制。
function error()  
{  
	echo -e "\033[31m发现异常：$1\033[0m" 1>&2
	exit 1
}

# 编译构建 gitbook
gitbook install
gitbook build

project_path=`pwd`
project_name=`basename $project_path`
project_gh_directory="/Users/yanglei/01_git/github_me_gh-pages"
project_gh_path=$project_gh_directory"/"$project_name
project_clone_url=`cat $project_path/.git/config | grep url | awk '{print $3}'`

# 调试参数
# error $project_gh_path

# 参数检查，判断是否手工创建了工程 gh-pages 分支存放目录
if [ ! -d $project_gh_directory ]; then
	error "gh-pages 目录：$project_gh_directory 未手工创建!"
fi

if [ ! -d $project_gh_path ]; then
	cd $project_gh_directory
	echo "$project_clone_url" | xargs git clone
fi

if [ ! -d $project_gh_path ]; then
	error "git clone $project_clone_url 失败!"
fi

cd $project_gh_path
git checkout gh-pages
ls $project_gh_path | xargs rm -rf
cp -r $project_path/_book/* $project_gh_path
git add --all 
echo "\"Publish book "`date +"%Y-%m-%d %H:%M:%S"`"\"" | xargs git commit -am 
git push
echo "增量发布成功"
