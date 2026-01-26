#!/bin/bash
set -e

FRP_VERSION="0.66.0"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"

SERVER_ADDR="38.47.123.76"
SERVER_PORT="7000"
TOKEN="99754106633f94d350db34d548d6091a"

RDS_HOST="staylp-prod.czmaiiccoc9e.ap-southeast-1.rds.amazonaws.com"
RDS_PORT="35432"

INSTALL_DIR="/usr/local/bin"
CONF_DIR="/etc/frp"
TMP_DIR="/tmp/frp_install"

echo "[1/4] 下载 frp..."
rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}
cd ${TMP_DIR}
wget -q ${FRP_URL}

echo "[2/4] 解压并安装 frpc..."
tar -zxf frp_${FRP_VERSION}_linux_amd64.tar.gz
cp frp_${FRP_VERSION}_linux_amd64/frpc ${INSTALL_DIR}/
chmod +x ${INSTALL_DIR}/frpc

echo "[3/4] 写入 frpc 配置..."
mkdir -p ${CONF_DIR}

cat > ${CONF_DIR}/frpc.toml <<EOF
serverAddr = "${SERVER_ADDR}"
serverPort = ${SERVER_PORT}

auth.method = "token"
auth.token = "${TOKEN}"

[[proxies]]
name = "rds-${RDS_PORT}"
type = "tcp"
localIP = "${RDS_HOST}"
localPort = ${RDS_PORT}
remotePort = ${RDS_PORT}
EOF

echo "[4/4] 启动 frpc..."
nohup frpc -c ${CONF_DIR}/frpc.toml >/var/log/frpc.log 2>&1 &

echo "===================================="
echo "frpc 已启动 ✅"
echo "RDS 已暴露到：${SERVER_ADDR}:${RDS_PORT}"
echo "日志文件：/var/log/frpc.log"
echo "===================================="
