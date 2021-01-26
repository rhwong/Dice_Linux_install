#!/usr/bin/env bash
while true

# 检测PID
check_pid() {
  PID=$(pgrep -f "mcl.jar")
}

do
 # 根据Dice打印的log查询
 logfile=$(ls -lrt /tmp/Mirai |awk '{print $NF}' | tail -n 1)
 # 检查程序是否出错，逻辑：日志中包含ERROR
 cat /tmp/Mirai/${logfile} | grep -E "kotlinx.coroutines.TimeoutCancellationException" > error
 # 判断 error文件是否为空，若不为空则执行if else 逻辑
 if [ -s error ]
 then
 # 检查 进程
  check_pid
  	if [[ ! -z "${PID}" ]]; then
     # 进程存在
      [[ -n ${PID} ]] && /etc/init.d/Mirai-Dice stop
     # 重启程序
      /etc/init.d/Mirai-Dice start
  		else
    # 未找到活动进程
      # 启动程序
      /etc/init.d/Mirai-Dice start
		fi
 fi
 sleep 20s
done