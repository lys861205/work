#!/bin/bash

#��ǰĿ¼
base_dir=`pwd`

#�����ļ�
CONF=${base_dir}/cfg.ini
SECTION=server


#�����ļ�
BAK_CONF=${base_dir}/cfg_bak.ini

#������� �ļ���
#����ֵ   0,�Ϸ�;����ֵ�Ƿ������
function check_syntax()
{
	if [ ! -f $1 ];then 
		return 1
	fi

	ret=$(awk -F= 'BEGIN{valid=1}
	{
		#�Ѿ��ҵ��Ƿ���,��һֱ�Թ�����
		if(valid == 0) next
		#���Կ���	
		if(length($0) == 0) next
		#�������еĿո�
		gsub(" |\t","",$0)	
		#����Ƿ���ע����	
		head_char=substr($0,1,1)
		if (head_char != "#"){
			#�����ֶ�=ֵ ��ʽ�ļ���Ƿ��ǿ���
			if( NF == 1){
				b=substr($0,1,1)
				len=length($0)
				e=substr($0,len,1)
				if (b != "[" || e != "]"){
					valid=0
				}
			}else if( NF == 2){
			#����ֶ�=ֵ ���ֶο�ͷ�Ƿ���[
				b=substr($0,1,1)
				if (b == "["){
					valid=0
				}
			}else{
			#���ڶ��=�ŷָ�Ķ��Ƿ�
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

#����1 �ļ���
#����2 ����
#����3 �ֶ���
#����0,��ʾ��ȷ,��������ַ�����ʾ�ҵ���Ӧ�ֶε�ֵ
#���������������ʾδ�ҵ���Ӧ���ֶλ����ǳ���
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

#�ű���Ҫ����
function main_process()
{
	#��������
	index=1  
	#���������ļ�
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
		#������1
		((index++))
		echo "===================ssh $IP start================="
		${base_dir}/ep_su.exp $IP $USER1 $PASSWORD1 $USER2 $PASSWORD2 "$SCRIPTFILE"
		echo "=================ssh $IP over===================="
	}
	done
	#ɾ��passwd��
	grep -i "^[^"passwd*"]"  $CONF >> $BAK_CONF
	more $BAK_CONF > $CONF
	if [ $? -ne 0 ]; then
		echo "more $BAK_CONF > $CONF failed"
	fi
	rm -f $BAK_CONF
}


#��ȡ�����ļ�
function read_conf()
{
	#����
	idx=1
	while :
	do
		echo "1"
	done
}
#����ļ��Ϸ���
check_syntax $CONF
if [ $? -ne 0 ] ; then
	echo "Please check ${CONF} exists firstly!"
else 
	main_process
fi




