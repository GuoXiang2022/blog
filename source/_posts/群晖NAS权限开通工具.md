---
title: 群晖NAS权限开通工具
date: 2024-06-17 00:00:00
tags:
    - Shell
    - NAS
---

####	解决问题：

日常中有大量的 NAS 访问权限申请，管理员通过群晖管理页面中找到申请的路径，点击属性赋予相应的权限。这类操作较为费时。比如路径非常复杂时，需要人工查找，且赋权需要手动勾选，可能会出现错，漏勾，造成问题的遗留。



####	基本原理：

群晖 NAS 服务器提供了 `synoacltool` 命令行工具，通过该工具可以直接对面文件赋权（类似 `chmod`）。根据日常工作中经常需要赋予的权限，定义好动作。相当于自己写了一个外壳，避免直接使用复杂 `synoacltool`。

将写好 shell 脚本，放到群晖 NAS 中。利用 python 中丰富的库，实现 SSH 连接到群晖 NAS 上，远程执行该脚本。



####	Shell 脚本：

```bash
#! /bin/bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/syno/bin

# acl: rwxpdDaARWcCo:fdin

declare -A aclhash
aclhash["r+"]="r-x---a-R-c--:fd--"
aclhash["rw+"]="rwxp--aARWc--:fd--"
aclhash["rwd+"]="rwxpdDaARWc--:fd--"

aclhash["r"]="r-x---a-R-c--:---n"
aclhash["rw"]="rwxp--aARWc--:---n"
aclhash["rwd"]="rwxpdDaARWc--:---n"

aclhash["root"]="rwxpdDaARWcCo:fd--"

declare -A aclhuman
aclhuman["r-x---a-R-c--:fd--"]="只读且继承"
aclhuman["rwxp--aARWc--:fd--"]="读写不可删除且继承"
aclhuman["rwxpdDaARWc--:fd--"]="读写可删除且可继承"

aclhuman["r-x---a-R-c--:---n"]="只读"
aclhuman["rwxp--aARWc--:---n"]="读写不可删除"
aclhuman["rwxpdDaARWc--:---n"]="读写可删除"

aclhuman["rwxpdDaARWcCo:fd--"]="完全控制"

aclhuman["null"]="无"

declare -A addmode
addmode["-add"]="单一赋值"
addmode["-chain_add"]="逐级赋值"
addmode["-limited_add"]="安全逐级赋值"
addmode["null"]="非赋值"
addmode["-chain_del"]="逐级删除"
time=$(date +'%Y-%m-%d %H:%M:%S')


printHelp() {
    cat << EOF
---------------------------------------------------------------------
    Used to assign permissions to users files on Synology NAS.
	
	nastool [OPTION]...

    Example: 
        nastool -h
        nastool -add 3203 '/volume1/foo/bar' rw+
        nastool -chain_add 3203 '/volume1/foo/bar' rw+
        nastool -limited_add 3203 '/volume1/foo/bar' rw+

        nastool -del 3203 '/volume1/foo/bar'
        nastool -get 3203 '/volume1/foo/bar'
        nastool -chain_del 3203 '/volume1/foo/bar'

        nastool -chain_add 3203 '/volume1/foo/bar' rw+ 
        is equivalent to
            nastool -add 3203 '/volume1/foo' rw+
            nastool -add 3203 '/volume1/foo/bar' rw+

        nastool -limited_add 3203 '/volume1/foo/bar' rw+
        is equivalent to
            nastool -add 3203 '/volume1/foo' r
            nastool -add 3203 '/volume1/foo/bar' rw+
----------------------------------------------------------------------
EOF
}

printErr() {
	echo "$1" >&2
}

printColor() {
	echo -e "\e[32m----$1----\e[0m"
}


getAclIndex() {
	local workID=$1
	local targetPath=$2
	aclEntry="$(synoacltool -get $targetPath | tail -n +5 | grep "$workID")"
	# echo "$aclEntry"
	if [[ ${#aclEntry} -gt 1 ]]; then
        aclSeq=$(echo "$aclEntry" | awk -F ':' 'NR == 1 {printf "%s:%s\n", $4, substr($5,1,4)}')
        aclIndex=${aclEntry:3:1}
		# echo "$aclIndex"
		# echo ">>>$aclSeq"
        pair=("$aclIndex" "$aclSeq")
    else
        return 1
    fi
}


getName() {
	echo "$(wbinfo -i "XXX-INC\\sy$1" | awk -F ':' '{print $5}')"
}


logging() {
	echo "$time -> $id:$name:$targetPath:${addmode["$1"]}:${aclhuman["$2"]}:$3" >> /volume1/synotool/log
}


# 参数的正确性检查
if [[ $1 == "-h" ]]; then
	printHelp && exit 0
fi

# [-inf, 2] || [5, +inf]
if [[ $# -le 2 || $# -ge 5 ]]; then
	printErr "The parameter is incorrect!" && printHelp && exit 1
elif ! wbinfo -i "XXX-INC\sy$2" &> /dev/null; then
	printErr "Invalid WorkID: sy$2!" && exit 1
elif [[ ! -e $3 ]]; then
	newpath=$3
	newpath="/volume2${newpath:8}"
	[[ ! -e "$newpath" ]] && printErr "$newpath : Path does not exist!" && exit 1
	targetPath=$newpath
fi

# 此时 选项, 工号, 路径 已无错误
op=$1
id=$2
[[ ${#newpath} -eq 0 ]] && targetPath=$3
name=$(getName "$id")

# 主逻辑
case "$op" in
	-get|-del|-chain_del)
		# /aaa/bbb/ccc 路径的最后一级目录必须有对应的权限！不然无法进行下一步。
		if ! getAclIndex "$id" "$targetPath"; then
			printColor "No permissions find" && exit 0
		fi
		
		# 最后一级目录的ACL
		permIdx=${pair[0]}
		permID=${pair[1]}

		if [[ $op == "-get" ]]; then
			printColor "sy$id:$name 权限为${aclhuman[$permID]}"
			logging "null" "null" "SEARCH_SUCCESSFUL" && exit 0
		elif [[ $op == "-del" ]]; then
			if ! synoacltool -del "$targetPath" "$permIdx" &> /dev/null; then
				printErr "ACL delete failed!" && exit 1
			fi
			logging "null" "null" "DELETED_SUCCESSFUL"
		else
			pathArr=()
			curPath=${targetPath%/}
			while [[ $curPath != /volume? ]]; do
				pathArr+=("$curPath")
				curPath=$(dirname "$curPath")
			done
			
			for (( i=${#pathArr[@]}-1; i>=0; i-- )); do
				curPath="${pathArr[i]}"
				if getAclIndex "$id" "$curPath"; then
					permIdx=${pair[0]}
					# echo "$curPath ---> deleted!"
					synoacltool -del "${pathArr[i]}" "$permIdx"  &> /dev/null
				fi
			done
			logging "-chain_del" "null" "DELETED_SUCCESSFUL"
		fi
		printColor "User permissions deleted successfully"
		;;
	-add|-chain_add|-limited_add)
		if [[ ! $4 =~ ^(r|rw|rwd|r\+|rw\+|rwd\+|root)$ ]]; then
			printHelp && exit 1
		fi
		perm=$4
		# 添加成功 更新成功 已存在 添加失败 替换失败
		addPerm() {
			if ! getAclIndex "$id" "$1"; then
				if ! synoacltool -add $1 user:sy$id@XXX-INC.COM:allow:${aclhash[$2]} &> /dev/null; then
					# echo "synoacltool -add $1 user:sy$id@XXX-INC.COM:allow:${aclhash[$2]}"
					# echo '4'
					return 1
				else
					# echo '1'
					return 0
				fi
			else
				permIdx=${pair[0]}
				permID=${pair[1]}
				if [[ $permID == "${aclhash[$2]}" ]]; then
					# echo '3'
					return 0
				elif ! synoacltool -replace $1 $permIdx user:sy$id@XXX-INC.COM:allow:${aclhash[$2]} &> /dev/null; then
					# echo '5'
					return 1
				fi
				echo '2'
			fi
		}

		if ! addPerm "$targetPath" "$perm"; then
			printErr "Permission assignment failed!" && exit 1
		fi
		curPath=$(dirname "$targetPath")
		if [[ "$op" == "-chain_add" ]]; then
			while [[ $curPath != /volume? ]]; do
				addPerm "$curPath" "$perm"
				curPath=$(dirname "$curPath")
			done
		elif [[ "$op" == "-limited_add" ]]; then
			while [[ $curPath != /volume? ]]; do
				addPerm "$curPath" "r"
				curPath=$(dirname "$curPath")
			done
		fi
		printColor "Permission assignment successfully" && logging "$op" "${aclhash[$perm]}" "ADD_SUCCESSFUL"
		;;
	*)
		printHelp && printErr "Unkown Error!" && exit 1
esac

# last moditfly: 24.6.2 19:03
```





####	Python 接口：

```python
from flask import Flask, request, jsonify

from dataclasses import dataclass

import app.Controllers.nastool.execsh as execsh
import ipaddress
import re

# @dataclass
#     nastool [OPTION]...

# Example: 
#     nastool -h
#     nastool -add 3203 '/volume1/foo' rw+
#     nastool -del 3203 '/volume1/foo'
#     nastool -get 3203 '/volume1/foo'

def bind_routes(app: Flask):
    print("注册函数")
    # 使用 route 装饰器将函数绑定到 URL
    @app.route('/nasGrant', methods=['POST'])
    def nasGrant():
        data = request.get_json()
        try:
            UNC_path = f"{data['content']}"
            workID = f"{data['id']}"
            mode=f"{data['mode']}"
            perm=f"{data['perm']}"
        except KeyError as e:
            return {"status": "error", "message": f"Missing {e} key"}
        else:
            pattern = r'\\\\([^\\]+)\\(.*)'
            match_obj = re.match(pattern, UNC_path)
            if match_obj is None:
                return {"status": "error", "message": "Error path"}
            server_address = match_obj.group(1)
            file_path = '/volume1/' + match_obj.group(2).replace('\\', '/')
            args = f"{mode} {workID} {file_path}"
            if perm != "null":
                args += f" {perm}"

            print(args)
            return execsh.run_ssh_command(server_address, "tooladm", "xxx", "/volume1/synotool/acltool", args)
```



```python
import paramiko
import re

#     nastool [OPTION]...

# Example: 
#     nastool -h
#     nastool -add 3203 '/volume1/foo' rw+
#     nastool -del 3203 '/volume1/foo'
#     nastool -get 3203 '/volume1/foo'


def run_ssh_command(hostname, username, password, script, args):
    # 创建 SSH 客户端
    client = paramiko.SSHClient()
    # 自动添加主机密钥
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        # 连接到远程主机
        client.connect(hostname, username=username, password=password)

        cmdtuple = f'{script} {args}'
        print(cmdtuple)

        # 执行命令
        stdin, stdout, stderr = client.exec_command(f"cd /volume1/synotool/ && {cmdtuple}")
        # 读取命令执行结果
        out = stdout.read().decode()
        err = stderr.read().decode()

        # 提取 shell 脚本中 printColor
        def getinfo(s):
            t = f'----(.*?)----'
            matchlist = re.findall(t, s)
            return matchlist[0] 
        
        exit_status = stdout.channel.recv_exit_status()
        if exit_status == 0:
            return {
                "msg": "success",
                "data": getinfo(out)
            }
        else:
            # ssh 登录时, 可能会产生用户没有 home 目录的标准错误输出, 需要过滤
            t = "/var/services/homes/tooladm: No such file or directory\n"
            return {
                "msg": "error",
                "data": err[err.find(t)+len(t):].replace('\n', '')
            }
    
    except paramiko.SSHException as e:
        return {
            "msg": "error",
            "data": "Connection to server timed out"
        }

    finally:
        client.close()
```

