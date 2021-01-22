# Dice Linux install

[Dice](https://github.com/Dice-Developer-Team/Dice) For Linux 快速安装脚本

## 简介

本脚本用于在 **CentOS/Debian/Ubuntu** 系统环境下快速部署[Mirai](https://github.com/project-mirai) with [Dice](https://github.com/Dice-Developer-Team)一键包 *(暂时只测试了Ubuntu)*

Mirai环境 以及 Dice核心 由 [@w4123](https://github.com/w4123) 溯洄制作和打包

本人仅在打包时为了适配脚本进行了一些文件的增加和修改

后续如果有官方Release可能会更改下载源

## 安装

下载脚本

`wget -N --no-check-certificate "https://raw.githubusercontent.com/rhwong/Dice_Linux_install/master/MiraiDice.sh"`

运行脚本

`bash MiraiDice.sh`

按照提示安装Dice即可

## 启动

安装成功后脚本默认会自动启动，但是这可能**不会成功**，原因是Mirai在登录时需要验证登录

这种情况有两种解决办法：

1. 控制台启动 `java -Dmirai.slider.captcha.supported -jar /usr/local/MiraiDice/mcl.jar`然后[手动完成滑块认证](https://github.com/project-mirai/mirai-login-solver-selenium#%E6%89%8B%E5%8A%A8%E5%AE%8C%E6%88%90%E6%BB%91%E5%8A%A8%E9%AA%8C%E8%AF%81)，之后即可正常登录。

2. 本地电脑预先使用Mirai进行登录认证，在Linux部署Mirai完成后，将设备信息文件`/Mirai/device.json`覆盖上传到`/usr/local/MiraiDice/device.json`，之后即可在Linux上正常登录。

如果是从Windows迁移到Linux服务器上，建议使用方法2，直接将本地`device.json`上传到服务器即可。

## 说明

本脚本旨在快速在Linux环境下部署Dice，但并没有考虑到同时部署多个bot的需求

如果有多个bot请注意修改`/etc/init.d/Mirai-Dice`文件中的`Start`和`Stop`部分

由于这种部署方式没有可视化界面，所以强烈建议先在本地部署，然后将`device.json`和`DiceQQ号`目录一起上传到`/usr/local/MiraiDice/`

另外可能会出现Openjdk安装失败的情况，请先更新安装源`apt-get update`

## 感谢

我就是个笨狐，啥都不会，脚本是照着Toyo/doubi抄的

安装包是由 [@w4123](https://github.com/w4123) 溯洄洄制作的，不是我做的

感谢以下项目的大佬们

Mirai https://github.com/project-mirai

Dice https://github.com/Dice-Developer-Team/Dice

doubi https://github.com/ToyoDAdoubiBackup/doubi