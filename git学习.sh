
# 回退到某一个commit，工作目录中的内容改变到commit-id对应的目录内容
git reset <commit-id> --hard    # git reset HEAD^ --hard 回退到上一个版本

# 如果本地仓库 push 远程仓库 出现错误，说明commit有不一致且无法调整的状态，需要回退，有时需要回退多次
git reset HEAD~3 --hard     # 回退到倒数第3个commit

# 目的：如果本地和远程仓库有冲突，将本地变更暂存起来，就可以从远程仓库下载最新代码
git stash save -m 'number_0'
git pull 
git stash list 
git stash pop stash@{0}  # 此时需要解决冲突【自动合并无法搞定】


# git push 出现 you are not allowed to upload merges 错误提示
git rebase
# 如果有冲突，修改
git add -u filename
git rebase --continue    直到没有冲突为止，无需commit

# Your branch is ahead of 'origin/Bigdata/Common/DataModel' by 1 commit 
出现原因：本地仓库commit，但是没有push到远程仓库，git push即可【gerrit上代码还没有通过review，所以会显示本地代码超前】



git branch -f master HEAD~3    # 将master分支强制指向前面3个的commit


gitk  # 图形界面查看 提交树

# 本地 git-workflow
git clone 下来的是 master版本
git checkout -b dev 创建 dev 分支，接下来所有的开发都在 dev分支 下进行，当完成一个功能模块后
git checkout master && git pull from remote && git merge dev
solve conflict

# git rebase使用 【不建议使用, 但是本地自己操作的时候可以保持提交时一条直线】
git clone
git checkout -b dev
进行新功能的开发
git checkout master
git pull 从远程仓库拉去更新后的代码，此时和dev分支会产生冲突
git checkout dev && git rebase master   此时dev提交的 new commit-id 会 变到 master最新commit的后面，此时提交变为了一条直线
vim xxx-file 解决冲突
git add .
git rebase --continue
git checkout master && git merge dev  此时提交变为了一条直线

# git 从 tracked 返回到 untracked 状态
git rm -r --cached <filePath>


# linux命令
vim 
  u-回退 ctrl+r-恢复 r-替换当前字符
  /<find_name>   查找
  

