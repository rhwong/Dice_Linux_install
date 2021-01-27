# Dice Linux install

[Dice](https://github.com/Dice-Developer-Team/Dice) For Linux 快速安装脚本

## 简介

本脚本用于在 **CentOS/Debian/Ubuntu** 系统环境下快速部署[Mirai](https://github.com/project-mirai) with [Dice](https://github.com/Dice-Developer-Team)一键包 _(暂时只测试了 CentOs/Ubuntu)_

Mirai 环境 以及 Dice 核心 由 [@w4123](https://github.com/w4123) 溯洄制作和打包

本人仅在打包时为了适配脚本进行了一些文件的增加和修改

后续如果有官方 Release 可能会更改下载源

## 安装

下载脚本

`wget -N --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/MiraiDice.sh"`

运行脚本

`bash MiraiDice.sh`

按照提示安装 Dice 即可

## 启动

安装成功后脚本默认会自动启动，但是这可能会提示已启动，但实际**没有正确运行**，原因是 Mirai 在登录时需要验证登录

这种情况有两种解决办法：

1.  `cd /usr/local/MiraiDice` -> `bash LaunchMirai.sh` 然后[手动完成滑块认证](https://github.com/project-mirai/mirai-login-solver-selenium#%E6%89%8B%E5%8A%A8%E5%AE%8C%E6%88%90%E6%BB%91%E5%8A%A8%E9%AA%8C%E8%AF%81)，之后即可正常登录。

2.  本地电脑预先使用 Mirai 进行登录认证，在 Linux 部署 Mirai 完成后，将设备信息文件`/Mirai/device.json`覆盖上传到`/usr/local/MiraiDice/device.json`，之后即可在 Linux 上正常登录。

如果是从 Windows 迁移到 Linux 服务器上，建议使用方法 2，直接将本地`device.json`上传到服务器即可。

## 说明

~~本脚本旨在快速在 Linux 环境下部署 Dice，但并没有考虑到同时部署多个 bot 的需求~~

~~如果有多个 bot 请注意修改`/etc/init.d/Mirai-Dice`文件中的`Start`和`Stop`部分~~

分身版已经做好了，照着和原版的差异改分身 C、D、E、F...就可以了

由于这种部署方式没有可视化界面，所以强烈建议先在本地部署，然后将`mirai/device.json`和`mirai/DiceQQ号`以及`mirai/config`目录一起上传到`/usr/local/MiraiDice/`

## 排错

1. 如果安装时出现无法连接 Github 的情况，请自行在`/etc/hosts`添加一行

   `199.232.4.133 raw.githubusercontent.com`

2. 出现 Openjdk 安装失败的情况，请先更新安装源`apt-get update`，然后`apt-get install openjdk-11-jre-headless`

## 更新说明

#### Ver 1.0.7

**增加进程守护功能**基本正确运行

#### Ver 1.0.6

debug

#### Ver 1.0.5

修正了进程守护无法读取对应目录的问题

#### Ver 1.0.4

**增加进程守护功能**，在检测 Mirai 出现自动重新登录失败导致的失去响应后重启 Mirai

注意：这样直接暴力重启会导致未被写入文件的 Dice 数据丢失，关于哪些数据非实时写入请参考 Dice 文档。

建议给 Dice 设置频繁的自动保存（比如半小时一次）以确保数据安全性。

#### Ver 1.0.3

**增加分身版**，使用 `wget -N --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/MiraiDice_B.sh"`

然后 `bash MiraiDice_.sh`

#### Ver 1.0.2

解决了提出问题的人

#### Ver 1.0.1

修正问题

#### Ver 1.0.0

创建项目

## 感谢

我就是个笨狐，啥都不会，脚本是照着 Toyo/doubi 抄的

安装包是由 [@w4123](https://github.com/w4123) 溯洄洄制作的，不是我做的

感谢以下项目的大佬们

Mirai https://github.com/project-mirai

Dice https://github.com/Dice-Developer-Team/Dice

doubi https://github.com/ToyoDAdoubiBackup/doubi
