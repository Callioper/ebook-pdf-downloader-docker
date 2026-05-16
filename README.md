# 📚 Ebook PDF Downloader (Docker)

> **GitHub:** https://github.com/Callioper/ebook-pdf-downloader-docker

[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)
[![OCR](https://img.shields.io/badge/OCR-PaddleOCR%20%7C%20Tesseract%20%7C%20LLM-orange?style=for-the-badge)](https://github.com/PaddlePaddle/PaddleOCR)
[![Platform](https://img.shields.io/badge/Platform-amd64%20%7C%20arm64-green?style=for-the-badge)](https://github.com/Callioper/ebook-pdf-downloader-docker)

> 四服务协同的电子书下载 / OCR / 智能目录 Docker 方案。全 OCR 引擎内置，支持 x86 和 ARM（群晖 / 威联通 / 绿联）。

---

## 镜像地址

| Registry | 适用 | 命令 |
|----------|------|------|
| **阿里云 ACR**（推荐） | 国内 | `docker pull crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest` |
| **Docker Hub** | 通用 | `docker pull elevenforhp/ebook-pdf-downloader-docker:latest` |
| **GitHub GHCR** | 国际 | `docker pull ghcr.io/callioper/ebook-pdf-downloader-docker:latest` |

---

## 四服务说明

| 服务 | 镜像 | 端口 | 用途 |
|------|------|:--:|------|
| **app** | ACR | 8000 | 主程序：搜索、下载、OCR、书签 |
| **stacks** | ACR | 7788 | AA 下载队列管理器（ACR 镜像由 Actions 自动同步） |
| **flaresolverr** | ACR | 8191 | Cloudflare / DDoS-Guard 绕过（ACR 镜像由 Actions 自动同步） |

> 三服务默认均使用阿里云 ACR（国内秒级拉取）。备选地址见"镜像地址"章节。

---

## 🚀 NAS 一键部署

部署前准备：

```bash
# 创建所需目录
mkdir -p /your-nas-path/ebook/{downloads,finished,tmp,db,stacks-config,stacks-logs}

# 从 EbookDatabase 下载 DX_2.0-5.0.db 放入 db 目录
# 下载地址: https://github.com/Hellohistory/EbookDatabase
cp DX_2.0-5.0.db /your-nas-path/ebook/db/
```

### 群晖 (Synology)

**Container Manager (DSM 7.2+)：**

1. Container Manager → 项目 → **新增** → 项目名称 `ebook`
2. 来源选"创建 docker-compose.yml"，粘贴：

```yaml
services:
  app:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest
    container_name: book-downloader
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "8000:8000"
    volumes:
      - /volume1/docker/ebook/downloads:/downloads
      - /volume1/docker/ebook/finished:/finished
      - /volume1/docker/ebook/tmp:/tmp/bdw
      - /volume1/docker/ebook/db:/db
      - config_data:/app/data
    restart: unless-stopped

  stacks:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/stacks:latest
    container_name: stacks
    stop_signal: SIGTERM
    stop_grace_period: 30s
    ports:
      - "7788:7788"
    volumes:
      - /volume1/docker/ebook/stacks-config:/opt/stacks/config
      - /volume1/docker/ebook/downloads:/opt/stacks/download
      - /volume1/docker/ebook/stacks-logs:/opt/stacks/logs
    environment:
      - USERNAME=admin
      - PASSWORD=password
      - SOLVERR_URL=flaresolverr:8191
      - TZ=Asia/Shanghai
    restart: unless-stopped

  flaresolverr:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/flaresolverr:latest
    container_name: flaresolverr
    ports:
      - "8191:8191"
    environment:
      - LOG_LEVEL=info
    restart: unless-stopped

volumes:
  config_data:
```

3. **下一步** → **完成**
4. 访问 `http://<NAS_IP>:8000`

---

### 威联通 (QNAP)

**Container Station：**

1. Container Station → **创建** → **创建应用程序**
2. 粘贴 YAML（路径已适配 QNAP）：

```yaml
services:
  app:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest
    container_name: book-downloader
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "8000:8000"
    volumes:
      - /share/Public/ebook/downloads:/downloads
      - /share/Public/ebook/finished:/finished
      - /share/Public/ebook/tmp:/tmp/bdw
      - /share/Public/ebook/db:/db
      - config_data:/app/data
    restart: unless-stopped

  stacks:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/stacks:latest
    container_name: stacks
    stop_signal: SIGTERM
    stop_grace_period: 30s
    ports:
      - "7788:7788"
    volumes:
      - /share/Public/ebook/stacks-config:/opt/stacks/config
      - /share/Public/ebook/downloads:/opt/stacks/download
      - /share/Public/ebook/stacks-logs:/opt/stacks/logs
    environment:
      - USERNAME=admin
      - PASSWORD=password
      - SOLVERR_URL=flaresolverr:8191
      - TZ=Asia/Shanghai
    restart: unless-stopped

  flaresolverr:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/flaresolverr:latest
    container_name: flaresolverr
    ports:
      - "8191:8191"
    environment:
      - LOG_LEVEL=info
    restart: unless-stopped

volumes:
  config_data:
```

3. File Station → Public → 创建 `ebook` 文件夹，内含六个子文件夹：
   `downloads` `finished` `tmp` `db` `stacks-config` `stacks-logs`
4. 将 `DX_2.0-5.0.db` 上传到 `db`
5. 创建 → 访问 `http://<NAS_IP>:8000`

> 私有镜像仓库需先添加：Container Station → 设置 → Registry → 新增 `crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com`，用户名改为你的 ACR 账号

---

### 绿联 (UGREEN)

支持 docker-compose 的话，参考群晖版 YAML，路径改为 `/volume1/docker/ebook/...` 即可。

如果不支持 compose，分别拉取四个镜像后手动创建容器，端口和路径同上。绿联 UGOS Pro 确认支持 compose 后，推荐直接用群晖版 YAML。

---

## 🖥️ Docker Compose 通用部署

适用于任何已安装 Docker 的 Linux / macOS / Windows。

```bash
# 1. 创建目录
mkdir -p ebook/{downloads,finished,tmp,db,stacks-config,stacks-logs}

# 2. 将 DX_2.0-5.0.db 放入 ebook/db/

# 3. 下载 docker-compose.yml
curl -O https://raw.githubusercontent.com/Callioper/ebook-pdf-downloader-docker/master/docker-compose.yml
cd ebook

# 4. 启动
docker compose up -d
```

> 本地构建：`git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git && cd ebook-pdf-downloader-docker && docker compose build && docker compose up -d`

---

## ⚙️ 初始化配置

访问 `http://<IP>:8000`，右上角 ⚙️ 进入设置。

> **三服务均使用阿里云 ACR**，Actions 自动同步。如遇拉取问题，检查是否已添加 ACR 私有仓库认证。

### 第一步：配置 Stacks（AA 下载服务器）

1. 访问 `http://<IP>:7788`，用户名 `admin`，密码 `stacks`
2. 进入 Settings → **修改密码** → 复制 API Key
3. 回到 app 设置页，填入：
   - `stacks_base_url`: `http://stacks:7788`
   - `stacks_api_key`: 刚才复制的 API Key

### 第二步：下载来源

| 配置项 | 说明 |
|--------|------|
| `zlib_email` / `zlib_password` | Z-Library 账号 |
| `http_proxy` | 代理地址。宿主机 Clash 填 `http://host.docker.internal:7890`（不要用 `192.168.x.x`） |

### 第三步：本地数据库

路径已默认 `/db`，`stacks_base_url` 设为 `http://stacks:7788` 后即可搜索本地数据库。

### OCR 引擎

| 引擎 | 说明 |
|------|------|
| **Tesseract**（默认） | 零配置 |
| **PaddleOCR** | 已内置，切换即可 |
| **LLM OCR** | 需同网运行 LM Studio/Ollama |

---

## 📂 目录说明

| 目录 | 存储内容 |
|------|------|
| `downloads/` | 下载中的 PDF（app + stacks 共享） |
| `finished/` | OCR 完成的最终 PDF |
| `tmp/` | 处理临时文件（可定期清理） |
| `db/` | SQLite 数据库文件（放入 `DX_*.db`） |
| `stacks-config/` | Stacks 配置文件 |
| `stacks-logs/` | Stacks 日志 |
| `config_data` (volume) | App 配置 + 任务记录 |

---

## 🔄 升级

```bash
docker compose pull
docker compose up -d
```

---

## 🛠️ 故障排查

| 问题 | 解决 |
|------|------|
| 搜索无结果 | 确认 `db/` 有 `DX_*.db`，`stacks_base_url` 正确 |
| AA 下载失败 | 检查 Stacks 是否运行，API Key 是否已填入设置页 |
| CF 绕过失败 | 确认 flaresolverr 容器运行中 |
| OCR 失败 | `docker compose logs app \| grep -i ocr` |
| PaddleOCR 不工作 | `docker compose logs app \| grep -i paddle` |
| LLM OCR 无响应 | 确认 LM Studio/Ollama 已启动 |
| 端口冲突 | 修改 compose 中 `ports` |
| 国内拉取慢 | 使用 ACR 地址 |
| 容器启动后秒退 | `docker compose logs` 查看错误 |

---

## 📄 许可证

MIT © Ebook PDF Downloader — 基于 [Callioper/ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) v1.3.0
