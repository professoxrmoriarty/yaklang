#!/bin/bash
set -e

# 获取最新版本号
VERSION=$(curl -s https://github.com/professoxrmoriarty/yaklang/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+(-\w+)?' | head -1)
echo "Checking latest version: ${VERSION}"

# yak -v checking
# Check if yak is installed and get current version
if command -v yak >/dev/null 2>&1; then
    CURRENT_VERSION=$( yak -v | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-\w+)?')
    if [ "$CURRENT_VERSION" == "$VERSION" ]; then
        echo "Current installed version ${CURRENT_VERSION} is the same as latest version"
        read -p "Do you want to reinstall? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation skipped"
            exit 0
        fi
        echo "Continuing installation..."
    else
        echo "Current version: ${CURRENT_VERSION}"
        echo "Latest version: ${VERSION}"
    fi
else
    echo "No yak installation detected, Start to download latest version"
fi


# 下载最新版本
# 根据系统和架构设置后缀
if [ "$(uname)" == "Darwin" ]; then
    if [ "$(uname -m)" == "arm64" ]; then
        suffix="darwin_arm64"
    else
        suffix="darwin_amd64"
    fi
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    if [ "$(uname -m)" == "aarch64" ]; then
        suffix="linux_arm64"
    else
        suffix="linux_amd64"
    fi
fi

echo "Downloading yak_${suffix}"
wget https://github.com/professoxrmoriarty/yaklang/releases/download/${VERSION}/yak_${suffix} -O yak_${suffix}


# 设置当前文件名
CURRENT_FILE="yak_${suffix}"

echo "Chmod +x yak_${suffix}"
chmod +x ./yak_${suffix}
echo 'println("Hello Yaklang!")' > hello.yak

# 检查安装是否成功
OUTPUT=$(./yak_${suffix} hello.yak)
if [[ "$OUTPUT" != *"Hello Yaklang"* ]]; then
    echo "Installation failed: Unable to execute yak command or unexpected output"
    rm hello.yak
    exit 1
fi
echo "Installation verification successful"
rm hello.yak

# add yak to PATH, if in darwin, sudo ./yak_${suffix} install
if [ "$(uname)" == "Darwin" ]; then
    echo "Adding yak to PATH (for MacOS)"
    sudo ./yak_${suffix} install
fi

if [ "$(uname)" == "Linux" ]; then
    echo "Adding yak to PATH (for Linux)"
    ./yak_${suffix} install
fi

echo "Cleaning cache file..."
rm ./${CURRENT_FILE}

echo "Installation completed"

# Check yak version
yak version || echo "yak command not found, please verify if installation was successful"