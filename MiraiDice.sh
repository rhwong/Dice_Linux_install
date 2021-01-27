#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: Mirai with Dice Quick install
#	Version: v1.0.7
#	Author: Linux Dice by w4123,bash by rhwong
# Thanks: Part of This script copied from Toyo 
#=================================================

sh_ver="1.0.7"
file="/usr/local/MiraiDice"
config_file="${file}/config/Console/AutoLogin.yml"
device_file="${file}/device.json"
DiceAPP_file="${file}/data/MiraiNative/plugins"
AutoShell_file="${file}/RestartService.sh"
log_file="/tmp/Mirai"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Separator_1="——————————————————————————————"

# 检查系统
check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif grep -q -E -i "debian" /etc/issue; then
    release="debian"
  elif grep -q -E -i "ubuntu" /etc/issue; then
    release="ubuntu"
  elif grep -q -E -i "centos|red hat|redhat" /etc/issue; then
    release="centos"
  elif grep -q -E -i "debian" /proc/version; then
    release="debian"
  elif grep -q -E -i "ubuntu" /proc/version; then
    release="ubuntu"
  elif grep -q -E -i "centos|red hat|redhat" /proc/version; then
    release="centos"
  fi
  bit=$(uname -m)
}

# 检测PID
check_pid() {
  #PID=$(ps -ef | grep "mcl.jar" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
  PID=$(pgrep -f "mcl.jar")
}

# 检测守护脚本PID
check_autorestart_pid() {
  A_PID=$(pgrep -f "RestartService.sh")
}

# 安装Openjdk
install_openjdk(){
		if [[ ${release} == "centos" ]]; then
			yum install openjdk-11-jre-headless
		else
			apt-get install openjdk-11-jre-headless
		fi
}

# 安装libcurl4
install_libcurl4(){
		if [[ ${release} == "centos" ]]; then
			yum install libcurl4
		else
			apt-get install libcurl4
		fi
}

# 安装libstdc++6
install_libstdc++6(){
		if [[ ${release} == "centos" ]]; then
			yum install libstdc++6
		else
			apt-get install libstdc++6
		fi
}

# 下载安装包
Download_Dice() {
   [[ ! -e ${file} ]] && mkdir "${file}"
  cd "${file}" || exit
  PID=$(ps -ef | grep "Dice" | grep -v "grep" | grep -v "init.d" | grep -v "service" | grep -v "Dice_install" | awk '{print $2}')
  [[ -n ${PID} ]] && kill -9 "${PID}"
  [[ -e "Dice*" ]] && rm -rf "Dice*"
  if [[ ${bit} == "x86_64" ]]; then
    wget --no-check-certificate -O "Dice_linux.tar.gz" "https://www.aobacore.com/Git/Mirai-Dice/Mirai_Dice_Linux_x86_64.tar.gz"
 	elif [[ ${bit} == "aarch64" ]]; then
		wget --no-check-certificate -O "Dice_linux.tar.gz" "https://www.aobacore.com/Git/Mirai-Dice/Mirai_Dice_Linux_aarch64.tar.gz"
  else
    echo -e "${Error_font_prefix}[错误]${Font_suffix} 不支持 [${bit}] ! 可能是还没有支持的内核类型，请在GitHub反馈[]内的名称。" && exit 1
  fi
  [[ ! -e "Dice_linux.tar.gz" ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} Dice 下载失败 !" && exit 1
  tar zxf "Dice_linux.tar.gz"
  rm -rf "Dice_linux.tar.gz"
  [[ ! -e ${file} ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} Dice 解压失败或压缩文件错误 !" && exit 1
  chmod +x /usr/local/MiraiDice
}

# 下载管理脚本
Service_Mirai_Dice_bash() {
  if [[ ${release} == "centos" ]]; then
    if ! wget --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/Service/Mirai-Dice-Service_CentOS" -O /etc/init.d/Mirai-Dice; then
      echo -e "${Error} Mirai-Dice 管理脚本下载失败 !" && exit 1
    fi
    chmod +x /etc/init.d/Mirai-Dice
    chkconfig --add Mirai-Dice
    chkconfig Mirai-Dice on
  else
    if ! wget --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/Service/Mirai-Dice-Service_Ubuntu" -O /etc/init.d/Mirai-Dice; then
      echo -e "${Error} Mirai-Dice 管理脚本下载失败 !" && exit 1
    fi
    chmod +x /etc/init.d/Mirai-Dice
    update-rc.d -f Mirai-Dice defaults
  fi
  echo -e "${Info} Mirai-Dice 管理脚本下载完成 !"
}

# 创建log目录
mkdir_Mirai_log_File() {
  if [[ -e ${log_file} ]]; then
   echo -e "${Info} Log目录已存在，跳过创建"
  else
   mkdir -p ${log_file}
   chmod +x ${log_file}
   echo -e "${Info} 已创建Log打印目录"
  fi
}

# 下载进程守护脚本
Service_Mirai_AutoRestart() {
  if [[ -e ${AutoShell_file} ]]; then
    echo && echo -e "${Error_font_prefix}[信息]${Font_suffix} 检测到 进程守护脚本 已存在，是否继续(覆盖安装)？[y/N]"
    read -rep "(默认: n):" yn
    [[ -z ${yn} ]] && yn="n"
    if [[ ${yn} == [Nn] ]]; then
      echo && echo "已取消..." && exit 1
    fi
     fi
    check_autorestart_pid
    [[ -n ${A_PID} ]] && kill -9 ${A_PID}
    mkdir_Mirai_log_File
    wget --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/AutoRestart/RestartService.sh" -O ${AutoShell_file}; 
    chmod +x ${AutoShell_file}
    echo -e "${Info} Mirai-Dice 守护脚本下载完成 ! (注意：因为更新方式是直接覆盖，如果守护正在运行可能被强行停止。)"

}

# 升级脚本
Update_Shell() {
  chmod +x MiraiDice.sh
  sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/MiraiDice.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 下载源 !" && exit 0
  if [[ -e "/etc/init.d/Mirai-Dice" ]]; then
    rm -rf /etc/init.d/Mirai-Dice
    Service_Mirai_Dice_bash
  fi
  wget -N --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/MiraiDice.sh" -O /root/MiraiDice.sh;
  chmod +x MiraiDice.sh
  echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}

# 升级核心
Update_Dice_Core() {
  core_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://www.aobacore.com/Git/Mirai-Dice/DiceVersion.sh" | grep 'Dice_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${core_new_ver} ]] && echo -e "${Error} 无法链接到 [${core_new_ver}]下载源 !" && exit 0
  if [[ ${bit} == "x86_64" ]]; then
    wget -N --no-check-certificate -P ${file}/data/MiraiNative/pluginsnew "https://www.aobacore.com/Git/Mirai-Dice/linuxcore/amd64/${core_new_ver}/com.w4123.dice.dll"
    wget -N --no-check-certificate -P ${file}/data/MiraiNative/pluginsnew "https://www.aobacore.com/Git/Mirai-Dice/linuxcore/amd64/${core_new_ver}/com.w4123.dice.json"
 	elif [[ ${bit} == "aarch64" ]]; then
		wget -N --no-check-certificate -P ${file}/data/MiraiNative/pluginsnew "https://www.aobacore.com/Git/Mirai-Dice/linuxcore/aarch64/${core_new_ver}/com.w4123.dice.dll"
    wget -N --no-check-certificate -P ${file}/data/MiraiNative/pluginsnew "https://www.aobacore.com/Git/Mirai-Dice/linuxcore/aarch64/${core_new_ver}/com.w4123.dice.json"
  else
    echo -e "${Error_font_prefix}[错误]${Font_suffix} 不支持 [${bit}] ! 可能是还没有支持的内核类型，请在GitHub或作者博客反馈[]内的名称。" && exit 1
  fi
  echo -e "核心已更新为最新版本[ ${core_new_ver} ] !(注意：因为更新方式为放入pluginsnew文件夹中，所以下次重启生效)" && exit 0
}

# 设置QQ号
Set_config_user(){
	while true
	do
	echo -e "请输入要登录的QQ"
	read -e -p "(不支持QID和手机号):" Dice_user
	[[ -z "$Dice_user" ]] && ssr_port="10000"
	echo $((${Dice_user}+0)) &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${Dice_user} -ge 1 ]] && [[ ${Dice_user} -le 999999999999 ]]; then
			echo && echo ${Separator_1} && echo -e "	QQ号 : ${Green_font_prefix}${Dice_user}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-999999999999)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-999999999999)"
	fi
	done
}

# 设置密码
Set_config_password(){
	echo "请输入要登录的QQ的密码"
	read -e -p "(默认: password):" Dice_password
	[[ -z "${Dice_password}" ]] && Dice_password="password"
	echo && echo ${Separator_1} && echo -e "	密码 : ${Green_font_prefix}${Dice_password}${Font_color_suffix}" && echo ${Separator_1} && echo
}

# 设置设备类型
Set_config_type(){
	echo "请输入要使用的登录协议：ANDROID_PHONE/ANDROID_PAD/ANDROID_WATCH"
	read -e -p "(默认ANDROID_WATCH，请务必全部为大写，建议直接复制上面的):" Dice_type
	[[ -z "${Dice_type}" ]] && Dice_type="ANDROID_WATCH"
	echo && echo ${Separator_1} && echo -e "	设备 : ${Green_font_prefix}${Dice_type}${Font_color_suffix}" && echo ${Separator_1} && echo
}

# 修改账号信息
Reset_QQ_config() {
if [ ! -e  ${config_file} ];then
  echo > ${config_file}
  Set_config_user
  Set_config_password
  Set_config_type
  sed -i '1i\     protocol: '"${Dice_type}"'' ${config_file}
  sed -i '1i\    configuration: ' ${config_file}
  sed -i '1i\  # "protocol": "ANDROID_PHONE" / "ANDROID_PAD" / "ANDROID_WATCH"' ${config_file}
  sed -i '1i\      value: '"${Dice_password}"'' ${config_file}
  sed -i '1i\      kind: PLAIN' ${config_file}
  sed -i '1i\    password: ' ${config_file}
  sed -i '1i\    account: '"${Dice_user}"'' ${config_file}
  sed -i '1i\  - ' ${config_file}
  sed -i '1i\accounts: ' ${config_file}
  else
      echo   && echo -e "${Error_font_prefix}[信息]${Font_suffix} 检测到 Dice 帐号配置已存在，是否覆盖信息？(第一次安装请无视本提示)[y/N]"
    read -rep "(默认: y):" yn
    [[ -z ${yn} ]] && yn="y"
    if [[ ${yn} == [Nn] ]]; then
      echo && echo "已取消..." && exit 1
    fi
  echo > ${config_file}
  Set_config_user
  Set_config_password
  Set_config_type
  sed -i '1i\     protocol: '"${Dice_type}"'' ${config_file}
  sed -i '1i\    configuration: ' ${config_file}
  sed -i '1i\  # "protocol": "ANDROID_PHONE" / "ANDROID_PAD" / "ANDROID_WATCH"' ${config_file}
  sed -i '1i\      value: '"${Dice_password}"'' ${config_file}
  sed -i '1i\      kind: PLAIN' ${config_file}
  sed -i '1i\    password: ' ${config_file}
  sed -i '1i\    account: '"${Dice_user}"'' ${config_file}
  sed -i '1i\  - ' ${config_file}
  sed -i '1i\accounts: ' ${config_file}
fi
  echo -e "${Info} 帐号信息写入成功 ${Green_font_prefix}[ QQ号码: ${Dice_user}, 登录类型: ${Dice_type}, 密码: ${Dice_password} ]${Font_color_suffix} !"
}

# 启动Linux Dice
Start_Mirai-Dice_Service() {
  check_pid
  [[ -n ${PID} ]] && echo -e "${Error} Mirai-Dice 正在运行，请检查 !" && exit 1
  /etc/init.d/Mirai-Dice start
}

# 停止Linux Dice
Stop_Mirai-Dice_Service() {
  check_pid
  [[ -z ${PID} ]] && echo -e "${Error} Mirai-Dice 没有运行，请检查 !" && exit 1
  /etc/init.d/Mirai-Dice stop
}
# 重启Linux Dice
Restart_Mirai-Dice_Service() {
  check_pid
  [[ -n ${PID} ]] && /etc/init.d/Mirai-Dice stop
  /etc/init.d/Mirai-Dice start
}

# 启动进程守护
Start_Mirai_AutoRestart() {
  check_autorestart_pid
  [[ -n ${A_PID} ]] && echo -e "${Error} 进程守护 正在运行，请检查 !" && exit 1
  /etc/init.d/Mirai-Dice startauto
}

# 关闭进程守护
Stop_Mirai_AutoRestart() {
  check_autorestart_pid
  [[ -z ${A_PID} ]] && echo -e "${Error} 进程守护 没有运行，请检查 !" && exit 1
  /etc/init.d/Mirai-Dice stopauto
}

# 重启进程守护
Restart_Mirai_AutoRestart() {
  check_autorestart_pid
  [[ -n ${A_PID} ]] && /etc/init.d/Mirai-Dice stopauto
  /etc/init.d/Mirai-Dice startauto
}


# 安装Linux Dice
install_Dice() {
  # 安装 依赖
  install_openjdk
  install_libcurl4
  install_libstdc++6
  if [[ -e ${file} ]]; then
    echo && echo -e "${Error_font_prefix}[信息]${Font_suffix} 检测到 Dice 已安装，是否继续安装(覆盖安装)？[y/N]"
    read -rep "(默认: n):" yn
    [[ -z ${yn} ]] && yn="n"
    if [[ ${yn} == [Nn] ]]; then
      echo && echo "已取消..." && exit 1
    fi
  fi
  # 调用下载
  Download_Dice
  Service_Mirai_Dice_bash
  Service_Mirai_AutoRestart
  mkdir_Mirai_log_File
  # 配置账号
  Reset_QQ_config
  echo && echo -e " ${Info_font_prefix}[信息]${Font_suffix} Dice 安装完成！请自行将device.json上传到/usr/local/MiraiDice才可免验证登录！" && echo
  Start_Mirai-Dice_Service
}

# 显示 菜单状态
menu_status(){
	if [[ -e ${file} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " Dice状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " Dice状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
		cd "${file}"
	else
		echo -e " Dice状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}

# 显示 守护状态
auto_status(){
	if [[ -e ${AutoShell_file} ]]; then
		check_autorestart_pid
		if [[ ! -z "${A_PID}" ]]; then
			echo -e " 守护状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 守护状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
		cd "${file}"
	else
		echo -e " 守护状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}

check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
action=$1
if [[ "${action}" == "clearall" ]]; then
	Clear_transfer_all
elif [[ "${action}" == "monitor" ]]; then
	crontab_monitor_dice
else
  echo && echo -e "  Dice! 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- rhwong | rhwong/Dice_Linux_install --
  -- Dice! by w4123 & Dice-Developer-Team --
 ${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
 ————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 Dice
 ${Green_font_prefix} 2.${Font_color_suffix} 安装 守护
————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 启动 Dice
 ${Green_font_prefix} 4.${Font_color_suffix} 停止 Dice
 ${Green_font_prefix} 5.${Font_color_suffix} 重启 Dice
————————————
 ${Green_font_prefix} 6.${Font_color_suffix} 启动 守护
 ${Green_font_prefix} 7.${Font_color_suffix} 关闭 守护
 ${Green_font_prefix} 8.${Font_color_suffix} 重启 守护
————————————
 ${Green_font_prefix} 9.${Font_color_suffix} 设置 登录信息
 "
	menu_status
  auto_status
	echo && read -e -p "请输入数字 [0-6]：" num
case "$num" in
  0)
    Update_Shell
    ;;
  1)
    install_Dice
    ;;
  2)
    Service_Mirai_AutoRestart
    ;;
  3)
    Start_Mirai-Dice_Service
    ;;
  4)
    Stop_Mirai-Dice_Service
    ;;
  5)
    Restart_Mirai-Dice_Service
    ;;
  6)
    Start_Mirai_AutoRestart
    ;;
  7)
    Stop_Mirai_AutoRestart
    ;;
  8)
    Restart_Mirai_AutoRestart
    ;;
  9)
    Reset_QQ_config
    ;;
  *)
	echo -e "${Error} 请输入正确的数字 [0-6]"
	;;
esac
fi