# OpenILink Hub - 懒猫应用

OpenILink Hub - 开源链接中心服务

## 应用信息

- **包名**: `cloud.lazycat.app.openilink-hub`
- **版本**: 1.0.0
- **最低系统版本**: 1.3.8

## 功能特点

- 开源链接中心服务
- 数据持久化到懒猫存储
- 自动健康检查
- 资源限制保护（512MB 内存）

## 数据持久化

应用数据自动持久化到：
```
/lzcapp/var/data/openilink.db
```

这是 OpenILink Hub 的标准数据目录，符合其跨平台数据目录规范：
- Linux: `~/.local/share/openilink-hub/`
- macOS: `~/Library/Application Support/openilink-hub/`
- 懒猫：`/lzcapp/var/data/` (自动映射)

## 访问方式

安装后，通过以下地址访问：
- 懒猫内部：`http://openilink-hub.lzcapp:9800`
- 外部访问：通过懒猫网关访问

## 本地测试

```bash
# Docker 方式测试
docker run -d -p 9800:9800 \
  -v ./data:/var/lib/openilink-hub \
  ghcr.io/openilink/openilink-hub:latest
```

## 懒猫安装

### 方式 1: 从应用商店安装（推荐）

```bash
lzc-cli app install cloud.lazycat.app.openilink-hub
```

### 方式 2: 本地构建安装

```bash
# 1. 构建 LPK 包
lzc-cli project build -o openilink-hub-1.0.0.lpk

# 2. 本地安装
lzc-cli app install openilink-hub-1.0.0.lpk
```

## 发布到应用商店

使用自动化脚本：

```bash
./build.sh
# 选择 4 - 一键发布
```

或手动执行：

```bash
# 1. 复制镜像到懒猫仓库
lzc-cli appstore copy-image ghcr.io/openilink/openilink-hub:latest

# 2. 更新 manifest 中的镜像地址（脚本自动完成）

# 3. 重新构建
lzc-cli project build -o openilink-hub-1.0.0.lpk

# 4. 发布
lzc-cli appstore publish openilink-hub-1.0.0.lpk
```

## 配置说明

此应用为零配置应用，无需填写任何参数即可安装使用。

## 资源需求

- CPU: 512 shares
- 内存：512MB
- 存储：根据实际数据量

## 健康检查

应用配置了自动健康检查：
- 检查间隔：60 秒
- 超时时间：10 秒
- 重试次数：3 次
- 启动宽限期：30 秒

## 版本历史

### 1.0.0
- 初始版本
- 基于 ghcr.io/openilink/openilink-hub:latest
- 支持数据持久化
- 自动健康检查

## 相关资源

- [项目主页](https://github.com/openilink/openilink-hub)
- [懒猫开发者文档](https://developer.lazycat.cloud)
