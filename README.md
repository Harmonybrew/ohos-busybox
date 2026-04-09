# ohos-busybox

本项目为 OpenHarmony 平台编译了 busybox，并发布预构建包。

本项目是 Harmonybrew 项目基础设施的一部分，主要供内部使用。我们也将其开源，有需要者可自取。

## 获取预构建包

前往 [release 页面](https://github.com/Harmonybrew/ohos-busybox/releases) 获取。

## 用法
**1\. 在鸿蒙 PC 中使用**

在 HiShell 中用 curl 下载这个软件包，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
cd ~
curl -fLO https://github.com/Harmonybrew/ohos-busybox/releases/download/1.37.0/busybox-1.37.0-ohos-arm64.tar.gz
tar -zxf busybox-1.37.0-ohos-arm64.tar.gz
export PATH=~/busybox-1.37.0-ohos-arm64/bin:$PATH

# 现在可以使用 busybox 命令了
```

**2\. 在鸿蒙开发板中使用**

用 hdc 把它推到设备上，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
hdc file send busybox-1.37.0-ohos-arm64.tar.gz /data
hdc shell

cd /data
tar -zxf busybox-1.37.0-ohos-arm64.tar.gz
export PATH=/data/busybox-1.37.0-ohos-arm64/bin:$PATH

# 现在可以使用 busybox 命令了
```

**3\. 在 [鸿蒙容器](https://github.com/hqzing/dockerharmony) 中使用**

在容器中用 curl 下载这个软件包，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
cd /opt
curl -fLO https://github.com/Harmonybrew/ohos-busybox/releases/download/1.37.0/busybox-1.37.0-ohos-arm64.tar.gz
tar -zxf busybox-1.37.0-ohos-arm64.tar.gz
export PATH=/opt/busybox-1.37.0-ohos-arm64/bin:$PATH

# 现在可以使用 busybox 命令了
```

## 从源码构建

**1\. 手动构建**

需要用一台 Linux x64 服务器来运行项目里的 build.sh，以实现 busybox 的交叉编译。

这里以 Ubuntu 24.04 x64 作为示例：
```sh
sudo apt update && sudo apt install -y build-essential unzip
git clone https://github.com/Harmonybrew/ohos-busybox.git
cd ohos-busybox
./build.sh
```

**2\. 使用流水线构建**

如果你熟悉 GitHub Actions，你可以直接复用项目内的工作流配置，使用 GitHub 的流水线来完成构建。

这种情况下，你使用的是 GitHub 提供的构建机，不需要自己准备构建环境。

只需要这么做，你就可以进行你的个人构建：
1. Fork 本项目，生成个人仓
2. 在个人仓的“Actions”菜单里面启用工作流
3. 在个人仓提交代码或发版本，触发流水线运行
