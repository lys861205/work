文件cfg.ini配置说明
1 配置文件是供脚本ssh.sh使用的，读取信息供ssh连接远程进行操作

2 配置文件格式ini，内容
   [server_1]
	ip=127.0.0.1
	user1=test1
	passwd1=123456
	user2=test2
	passwd1=123456
	file=/home/ftotp/t.sh;/home/ftotp/t1.sh
如果有多个服务器，可以添加section, 格式如上。注意：section的索引从1开始，必须依次递增。

3 配置文件各项说明
[server_1]是section，下个必须是[server_2] 依次递增
ip 		        ssh远程的主机ip地址
user1           ssh登录远程的用户名
passwd1      用户user1的密码
user2           ssh登录user1之后，sudo的用户
passwd2      用户user2的密码
file			   远程主机上要执行的脚本(全路径)，可以有多个，每个脚本之间用分号隔开

4 脚本执行完之后，会删除密码项，如；
	  [server_1]
	   ip=127.0.0.1
	   user1=test1
	   user2=test2
	   file=/home/ftotp/t.sh;/home/ftotp/t1.sh

下次执行之前，必须在user1下添加passwd1=******* 
								  在user2下添加passwd2=*******  
