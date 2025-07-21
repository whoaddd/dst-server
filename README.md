# 饥荒服务器搭建

本项目使用旧电脑及docker搭建饥荒服务器，对旧电脑配置要求不高（1GB RAM 以上，双核 CPU），服务器采用ubuntu系统，可在ubuntu官网下载镜像安装。

# 资源下载

```
git clone https://github.com/whoaddd/dst-server.git
```

# 基础准备

开始前需安装docker和docker compose,由于旧电脑无法访问dockerhub,需要提前准备好需要的镜像，本教程使用Ubuntu20.04镜像，代码仓库中含有镜像压缩包，

```
# 更新系统
sudo apt update && sudo apt upgrade -y

# 添加Docker仓库
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 安装Docker Compose（v2.x）
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# 验证安装
docker --version
docker compose version  # 注意中间有空格

# 添加当前用户到docker组
sudo usermod -aG docker $USER

# 解压镜像命令
docker load -i Ubuntu.tar
```

# 服务器资源下载

由于docker中可能导致steamcmd下载问题，我们使用映射的方式安装服务器资源

1. **安装依赖项**：打开终端，根据系统类型安装必要的依赖项。对于 Ubuntu 系统，可运行以下命令：

```bash
sudo add-apt-repository multiverse
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libstdc++6 libgcc1 libcurl4-gnutls-dev:i386 lib32z1
```

1. **下载并解压 SteamCMD**：创建一个用于存放 SteamCMD 的文件夹并进入该文件夹，然后使用`wget`命令下载 SteamCMD 安装包，最后解压安装包。具体命令如下：

```bash
mkdir ~/steamcmd
cd ~/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
```

1. **启动 SteamCMD**：在终端中输入以下命令启动 SteamCMD：

```bash
./steamcmd.sh
```

当命令行提示符变为`steam>`，表示 SteamCMD 启动成功。

4. **下载饥荒服务器**：使用`login anonymous`命令匿名登录 Steam，最后通过`app_update`命令下载饥荒服务器，命令如下：

```bash
force_install_dir ../dontstarvetogether_dedicated_server
login anonymous
app_update 343050 validate
```

其中`343050`是饥荒服务器在 Steam 上的 App ID，`validate`参数会在下载后验证文件完整性。

5. **退出 SteamCMD**：下载完成后，输入`quit`命令退出 SteamCMD。

# 启动阶段

## 修改游戏文件名称

```
# 进入Steam游戏目录
cd ~/Steam/steamapps/common/

# 重命名目录（去除单引号和空格）
mv "Don't Starve Together Dedicated Server" dst_server
```

## 获取游戏令牌

打开饥荒游戏并登录，左下角账户数据——游戏——创建服务器并获取服务器票据，复制票据并粘贴到dst-server/config/MyDediServer/cluster_token.txt

## 启动服务器

```
# 切换目录
cd dst-server
# 构建镜像
docker compose build
# 启动容器
docker compose up -d
# 赋予启动脚本权限
chmod +x start.sh
# 启动服务器
./start.sh
# 关闭服务器
docker compose stop
```

正常情况下服务器即可启动，但可能出现其他问题

# 端口开放

饥荒默认游戏端口为10999，11000，11001

```
sudo ufw allow 10999/udp
sudo ufw allow 11000/udp
sudo ufw allow 11001/udp
```

# 本地连接

打开游戏，左上角~建打开控制台，输入c_connect("ip地址"，10999)

# 异地连接

由于旧电脑连接wifi没有公网ip，无法被公网访问，因此需要内网穿透，这里使用的樱花内网穿透，需注册账号并购买使用

## 服务器端安装

在旧电脑终端中下载樱花官方frp，按指应绑定账号，并在浏览器控制面板中 服务——远程管理——创建隧道

```
# 安装frp
sudo bash -c ". <(curl -sSL https://doc.natfrp.com/launcher.sh)"
# 隧道ip为127.0.0.1，端口为10999，查看日志中提供的IP和端口进行连接
```

## 客户端连接

使用VScode连接服务器，添加端口转发10999，11000，11001，打开樱花内网穿透软件，创建隧道，IP地址为127.0.0.1，端口10999，服务器与使用电脑在同一网关下，也可以使用服务器ip进行创建隧道