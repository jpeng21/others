# git使用技巧

## 克隆仓库
git clone reposity -b brach

## 更新submodule
git submodule update --init

.gitignore文件 

git status时，报文件权限修改： 
	git config --add core.filemode false

查看文件类型是否被篡改
  git status | grep 'modified:' | awk {'print $2'} | xargs file
