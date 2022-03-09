# lightweight init min-centos7

after  install  centos7 , init config for develop!

## 安装说明

- 1.直接在终端运行命令克隆这个项目：
```SH
wget -qO https://raw.github.com/cugbtang/init-min-centos/main/setup.sh | sh -x
国内的走这里：
curl -L https://ghproxy.com/https://raw.github.com/cugbtang/init-min-centos/main/setup.sh | sh -x
```
- 2.运行文件scripts/startup.sh来进行安装
- 3.在安装的过程中需要有人值守，来确认每一步的安装

## 配置内容

- 修改yum资源库为阿里的镜像
- 升级系统，安装开发编译包及常用软件
- 添加具有root权限的用户
- 关闭防火墙和selinux
- 禁用ipv6
- 修改文件描述符数量
- 优化SSH配置
- 优化network配置
- 优化history配置
- 时间同步
- 安装docker-ce
