�ļ�cfg.ini����˵��
1 �����ļ��ǹ��ű�ssh.shʹ�õģ���ȡ��Ϣ��ssh����Զ�̽��в���

2 �����ļ���ʽini������
   [server_1]
	ip=127.0.0.1
	user1=test1
	passwd1=123456
	user2=test2
	passwd1=123456
	file=/home/ftotp/t.sh;/home/ftotp/t1.sh
����ж�����������������section, ��ʽ���ϡ�ע�⣺section��������1��ʼ���������ε�����

3 �����ļ�����˵��
[server_1]��section���¸�������[server_2] ���ε���
ip 		        sshԶ�̵�����ip��ַ
user1           ssh��¼Զ�̵��û���
passwd1      �û�user1������
user2           ssh��¼user1֮��sudo���û�
passwd2      �û�user2������
file			   Զ��������Ҫִ�еĽű�(ȫ·��)�������ж����ÿ���ű�֮���÷ֺŸ���

4 �ű�ִ����֮�󣬻�ɾ��������磻
	  [server_1]
	   ip=127.0.0.1
	   user1=test1
	   user2=test2
	   file=/home/ftotp/t.sh;/home/ftotp/t1.sh

�´�ִ��֮ǰ��������user1�����passwd1=******* 
								  ��user2�����passwd2=*******  
