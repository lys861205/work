#!/bin/bash

#当前目录
base_dir=`pwd`

#配置文件
CONF=${base_dir}/cfg.ini
SECTION=server


#备份文件
BAK_CONF=${base_dir}/cfg_bak.ini

#传入参数 文件名
#返回值   0,合法;其他值非法或出错
function check_syntax()
{
	if [ ! -f $1 ];then 
		return 1
	fi

	ret=$(awk -F= 'BEGIN{valid=1}
	{
		#已经找到非法行,则一直略过处理
		if(valid == 0) next
		#忽略空行	
		if(length($0) == 0) next
		#消除所有的空格
		gsub(" |\t","",$0)	
		#检测是否是注释行	
		head_char=substr($0,1,1)
		if (head_char != "#"){
			#不是字段=值 形式的检测是否是块名
			if( NF == 1){
				b=substr($0,1,1)
				len=length($0)
				e=substr($0,len,1)
				if (b != "[" || e != "]"){
					valid=0
				}
			}else if( NF == 2){
			#检测字段=值 的字段开头是否是[
				b=substr($0,1,1)
				if (b == "["){
					valid=0
				}
			}else{
			#存在多个=号分割的都非法
				valid=0
			}	
		}
	}
	END{print valid}' $1)
	
	if [ $ret -eq 1 ];then
		return 0
	else
		return 2
	fi
}

#参数1 文件名
#参数2 块名
#参数3 字段名
#返回0,表示正确,且能输出字符串表示找到对应字段的值
#否则其他情况都表示未找到对应的字段或者是出错
function get_field_value()
{
	if [ ! -f $1 ] || [ $# -ne 3 ];then
		return 1
	fi
blockname=$2
fieldname=$3

begin_block=0
end_block=0

	cat $1 | while read line
	do
	
		if [ "X$line" = "X[$blockname]" ];then
			begin_block=1
			continue
		fi
		
		if [ $begin_block -eq 1 ];then
			end_block=$(echo $line | awk 'BEGIN{ret=0} /^\[.*\]$/{ret=1} END{print ret}')
			if [ $end_block -eq 1 ];then
				#echo "end block"
				break
			fi
	
			need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^#/{ret=1} /^$/{ret=1} END{print ret}')
			if [ $need_ignore -eq 1 ];then
				#echo "ignored line:" $line
				continue
			fi
			field=$(echo $line | awk -F= '{gsub("|\t","",$1); print $1}')
			value=$(echo $line | awk -F= '{gsub("|\t","",$2); print $2}')
			#echo "'$field':'$value'"
			if [ "X$fieldname" = "X$field" ];then	
				#echo "result value:'$result'"
				echo $value
				break
			fi
			
		fi
	done
	return 0
}

#脚本主要操作
function main_process()
{
	#块名索引
	index=1  
	#解析配置文件
	while :
	do {
		#ip
		IP=$(get_field_value $CONF ${SECTION}_$index ip)
		if [ -z "$IP" ]; then
			echo "prase $CONF [${SECTION}_$index] ip empty or finish!"
			break
		fi
		
		#user1
		USER1=$(get_field_value $CONF ${SECTION}_$index user1)
		if [ -z "$USER1" ]; then
			echo "prase $CONF [${SECTION}_$index] user1 empty!"
			break
		fi
		
		#passwd1
		PASSWORD1=$(get_field_value $CONF ${SECTION}_$index passwd1)
		if [ -z "$PASSWORD1" ]; then
			echo "prase $CONF [${SECTION}_$index] passwd1 empty!"
			break
		fi
		
		#user2
		USER2=$(get_field_value $CONF ${SECTION}_$index user2)
		if [ -z "$USER2" ]; then
			echo "prase $CONF [${SECTION}_$index] user2 empty!"
			break
		fi
		
		#passwd2
		PASSWORD2=$(get_field_value $CONF ${SECTION}_$index passwd2)
		if [ -z "$PASSWORD2" ]; then
			echo "prase $CONF [${SECTION}_$index] passwd2 empty!"
			break
		fi
		
		#execute script file
		SCRIPTFILE=$(get_field_value $CONF ${SECTION}_$index file)
		if [ -z "$SCRIPTFILE" ]; then
			echo "prase $CONF [${SECTION}_$index] file empty!"
			break
		fi
		#索引加1
		((index++))
		echo "===================ssh $IP start================="
		${base_dir}/ep_su.exp $IP $USER1 $PASSWORD1 $USER2 $PASSWORD2 "$SCRIPTFILE"
		echo "=================ssh $IP over===================="
	}
	done
	#删除passwd行
	grep -i "^[^"passwd*"]"  $CONF >> $BAK_CONF
	more $BAK_CONF > $CONF
	if [ $? -ne 0 ]; then
		echo "more $BAK_CONF > $CONF failed"
	fi
	rm -f $BAK_CONF
}


#读取配置文件
function read_conf()
{
	#索引
	idx=1
	while :
	do
		echo "1"
	done
}
#检查文件合法性
check_syntax $CONF
if [ $? -ne 0 ] ; then
	echo "Please check ${CONF} exists firstly!"
else 
	main_process
fi




