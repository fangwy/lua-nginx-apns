#!/bin/bash
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
cd $SHELL_FOLDER
mkdir -p logs & mkdir -p tmp


if [ ! -x /usr/local/openresty/bin/openresty ]; then
    NGX=/usr/local/openresty/bin/nginx
else
    NGX=/usr/local/openresty/bin/openresty
fi;

# 默认不更新
is_close=0
is_start=0
is_reload=0
is_restart=0
is_update=0
is_change_branch=0
is_change_version=0
is_ptname=0

is_tail=0
# 当前分支
_branch=$(git branch -l| awk '{if($1 == "*") print $2}')
# 当前版本号
_version=$(git log --oneline|head -1|awk '{print $1}')

# 读取参数
while getopts thuscqrb:v:n: opt
do
    case "$opt" in
        b) _branch=$OPTARG;is_change_branch=1 ;;
        v) _version=$OPTARG;is_change_version=1 ;;
        n) _ptname=$OPTARG;is_pt_name=1 ;;
        u) is_update=1 ;;
        r) is_reload=1 ;;
        s) is_start=1 ;;
        q) is_restart=1 ;;
        c) is_close=1 ;;
        t) is_tail=1 ;;
        h) echo "usage: $0      -u 是否更新" && echo "      -v 重置到版本号 " && echo "      -b 切换到分支名 "
            echo "      -r 重启子进程" && echo "      -s 启动服务器" && echo "      -c 关闭服务器"
            echo "      -t 是否看日志"
            exit -2
            ;;
#        *) echo "Unknown option: $opt" && exit -2 ;;
    esac
done

#取得守护进程ID
PID=$(ps -ef|grep "$SHELL_FOLDER/"|grep nginx | grep -v grep | awk '{if($3==1) print $2}')

#验证分支及版本号


#判断字符串是是否为空
cmd="echo 是否更新:$is_update 是否切分支:$is_change_branch 是否切版本:$is_change_version 前往分支:$_branch 前往版本:$_version"
if [ $is_change_branch == 1 ]; then
    cmd="$cmd && git fetch && git checkout $_branch && git submodule update"
fi
if [ $is_update == 1 ]; then
	BRANCH=$(git branch -l| grep ^*|awk '{print $2}')
    cmd="$cmd && git pull origin $BRANCH && git submodule update"
fi
if [ $is_change_version == 1 ]; then
    cmd="$cmd && git reset --hard $_version"
fi
eval $cmd
if [ ! $is_ptname ]; then
    PROFILE="$_ptname"
else
    PROFILE=dev 
fi
if [ $is_reload == 1 ]; then
    # 验证当前进程是否存在
    if [ -z $PID ] ; then
        echo "reload error,进程数量:$ps,请先启动服务器!"
        exit -1
    else $NGX -s reload -p `pwd`/ -c conf/nginx-$PROFILE.conf
    fi
elif [ $is_start == 1 ]; then
    if [ ! -z $PID ] ; then
        echo "服务器运行中 守护者程:$PID"
        exit -1
    else $NGX -p `pwd`/ -c conf/nginx-$PROFILE.conf
        sleep 1
        PID=$(ps -ef|grep $SHELL_FOLDER | grep -v grep | awk '{if($3==1) print $2}')
        echo "启动成功!进程 $PID "
    fi
elif [ $is_close == 1 ]; then
    if [ -z $PID ] ; then
        echo "服务器已是关闭状态!"
        exit 0
    else 
	$NGX -s stop -p `pwd`/ -c conf/nginx-$PROFILE.conf
	echo "服务器关闭成功!"
    fi
elif [[ $is_restart == 1 ]]; then
    if [ -z $PID ] ; then
        echo "reload error,进程数量:$ps,请先启动服务器!"
        exit -1
    else echo "停止进程 $PID " && $NGX -s stop -p `pwd`/ -c conf/nginx-$PROFILE.conf && $NGX -p `pwd`/ -c conf/nginx-$PROFILE.conf
        sleep 1
        PID=$(ps -ef|grep $SHELL_FOLDER | grep -v grep | awk '{if($3==1) print $2}')
        echo "停止&&启动成功!进程 $PID "
    fi
fi
