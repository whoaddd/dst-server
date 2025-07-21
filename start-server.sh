#!/bin/bash

DST_SERVER_DIR="/dst-server"
# 游戏可执行文件路径（对应容器内的bin目录）
GAME_EXE="${DST_SERVER_DIR}/bin/dontstarve_dedicated_server_nullrenderer"

# 检查游戏文件是否存在
if [ ! -f "${GAME_EXE}" ]; then
    echo "错误：未找到游戏可执行文件！"
    echo "容器内实际路径：${GAME_EXE}"
    echo "宿主机映射路径：~/Steam/steamapps/common/dst_server/bin/"
    echo "容器内bin目录内容："
    ls -la ${DST_SERVER_DIR}/bin
    exit 1
fi

# 确保配置目录存在（现在/dst-server是可写的，可创建子目录）
mkdir -p ${DST_SERVER_DIR}/config/MyDediServer/{Master,Caves}

# 检查集群令牌
if [ ! -f "${DST_SERVER_DIR}/config/MyDediServer/cluster_token.txt" ]; then
    echo "错误：未找到集群令牌！请在宿主机的 ./config/MyDediServer/ 目录下创建 cluster_token.txt"
    exit 1
fi

# 启动主服务器（指定bin目录下的可执行文件）
echo "启动主服务器..."
screen -dmS dst_master ${GAME_EXE} \
    -console -cluster MyDediServer -shard Master

# 启动洞穴服务器（可选）
if [ -f "${DST_SERVER_DIR}/config/MyDediServer/Caves/server.ini" ]; then
    echo "启动洞穴服务器..."
    screen -dmS dst_caves ${GAME_EXE} \
        -console -cluster MyDediServer -shard Caves
fi

# 保持容器运行
echo "服务器启动成功！"
echo "主服务器控制台：screen -r dst_master"
echo "洞穴服务器控制台：screen -r dst_caves"
tail -f /dev/null