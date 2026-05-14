# 📚 Ebook PDF Downloader (Docker)

> **GitHub:** https://github.com/Callioper/ebook-pdf-downloader-docker

[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)
[![OCR](https://img.shields.io/badge/OCR-PaddleOCR%20%7C%20Tesseract%20%7C%20LLM-orange?style=for-the-badge)](https://github.com/PaddlePaddle/PaddleOCR)
[![Platform](https://img.shields.io/badge/Platform-amd64%20%7C%20arm64-green?style=for-the-badge)](https://github.com/Callioper/ebook-pdf-downloader-docker)

> 一键部署的电子书下载 / OCR / 智能目录 Docker 方案。三服务协同（app + stacks + flaresolverr），全 OCR 引擎内置，支持 x86 和 ARM。

---

## 镜像地址

| Registry | 适用 | 命令 |
|----------|------|------|
| **阿里云 ACR**（推荐） | 国内 | `docker pull crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest` |
| **Docker Hub** | 通用 | `docker pull elevenforhp/ebook-pdf-downloader-docker:latest` |
| **GitHub GHCR** | 国际 | `docker pull ghcr.io/callioper/ebook-pdf-downloader-docker:latest` |

---

## 🚀 NAS 一键部署

部署前先创建目录结构并下载数据库：

```bash
# 创建所需目录
mkdir -p /your-nas-path/ebook/{downloads,finished,tmp,db}

# 从 EbookDatabase 下载 DX_2.0-5.0.db，放入 db 目录
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
    image: ghcr.io/callioper/book-searcher:latest
    container_name: book-searcher
    ports:
      - "7788:7788"
    volumes:
      - /volume1/docker/ebook/db:/data
    restart: unless-stopped

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
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
    image: ghcr.io/callioper/book-searcher:latest
    container_name: book-searcher
    ports:
      - "7788:7788"
    volumes:
      - /share/Public/ebook/db:/data
    restart: unless-stopped

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    ports:
      - "8191:8191"
    environment:
      - LOG_LEVEL=info
    restart: unless-stopped

volumes:
  config_data:
```

3. File Station → Public → 创建 `ebook` 文件夹，内含 `downloads` `finished` `tmp` `db` 四个子文件夹
4. 将 `DX_2.0-5.0.db` 上传到 `db` 目录
5. 创建 → 访问 `http://<NAS_IP>:8000`

> 私有镜像仓库需先添加：Container Station → 设置 → Registry → 新增 `crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com`，用户 `yy981204`

---

### 绿联 (UGREEN)

**UGOS Pro Docker：**

1. Docker 应用 → 镜像 → 拉取 → `crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest`
2. 同样拉取 `ghcr.io/callioper/book-searcher:latest` 和 `ghcr.io/flaresolverr/flaresolverr:latest`
3. 创建三个容器，端口和路径映射如下：

**app 容器：**
| 容器内路径 | 宿主机路径 |
|---|---|
| `/downloads` | `/volume1/docker/ebook/downloads` |
| `/finished` | `/volume1/docker/ebook/finished` |
| `/tmp/bdw` | `/volume1/docker/ebook/tmp` |
| `/db` | `/volume1/docker/ebook/db` |
| 端口 | `8000:8000` |

**stacks 容器：**
| 容器内路径 | 宿主机路径 |
|---|---|
| `/data` | `/volume1/docker/ebook/db` |
| 端口 | `7788:7788` |

**flaresolverr 容器：**
| 环境变量 | `LOG_LEVEL=info` |
| 端口 | `8191:8191` |

4. 三个容器全部启动 → 访问 `http://<NAS_IP>:8000`

> 如果你的绿联支持 docker-compose，直接在数据目录创建 `docker-compose.yml`（参考群晖版，修改路径前缀），一条命令启动全部服务。

---

## 🖥️ Docker Compose 通用部署

适用于任何已安装 Docker 的 Linux / macOS / Windows。

```bash
# 1. 创建目录并下载数据库
mkdir -p ebook/{downloads,finished,tmp,db}
# 将 DX_2.0-5.0.db 放入 ebook/db/

# 2. 拉取镜像（可选，compose 会自动拉取）
docker pull crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest

# 3. 创建 docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  app:
    image: crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest
    container_name: book-downloader
    ports:
      - "8000:8000"
    volumes:
      - ./downloads:/downloads
      - ./finished:/finished
      - ./tmp:/tmp/bdw
      - ./db:/db
      - config_data:/app/data
    restart: unless-stopped

  stacks:
    image: ghcr.io/callioper/book-searcher:latest
    container_name: book-searcher
    ports:
      - "7788:7788"
    volumes:
      - ./db:/data
    restart: unless-stopped

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    ports:
      - "8191:8191"
    environment:
      - LOG_LEVEL=info
    restart: unless-stopped

volumes:
  config_data:
EOF

# 4. 启动
docker compose up -d
```

> 如已有 git 环境，也可 `git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git && cd ebook-pdf-downloader-docker && docker compose build && docker compose up -d` 本地编译。

---

## ⚙️ 初始化配置

访问 `http://<IP>:8000`，右上角 ⚙️ 进入设置。

### 第一步：下载来源

| 配置项 | 说明 |
|--------|------|
| `zlib_email` / `zlib_password` | Z-Library 账号 |
| `stacks_base_url` | `http://stacks:7788`（容器地址，已默认） |
| `flaresolverr_port` | `8191`（已默认） |
| `http_proxy` | 代理地址（国内访问 Z-Library/AA 必须） |

### 第二步：数据库

路径已默认 `/db`，无需修改。确认 `stacks_base_url` 为 `http://stacks:7788` 后，在首页即可搜索本地数据库。

### OCR 引擎

| 引擎 | 说明 |
|------|------|
| **Tesseract**（默认） | 零配置 |
| **PaddleOCR** | 已内置，切换即可，中文效果最佳 |
| **LLM OCR** | 需同网运行 LM Studio/Ollama |

---

## 📂 目录说明

| 目录 | 存储内容 |
|------|------|
| `downloads/` | 下载中的 PDF 临时文件 |
| `finished/` | OCR 完成的最终 PDF |
| `tmp/` | 处理临时文件（可定期清理） |
| `db/` | SQLite 数据库 + Stacks 索引 |
| `config_data` (volume) | 配置文件 + 任务记录 |

---

## 🔄 升级

```bash
docker compose pull
docker compose up -d
```

配置和任务记录保留不变。

---

## 🛠️ 故障排查

| 问题 | 解决 |
|------|------|
| 搜索无结果 | 确认 `db/` 目录有 `DX_*.db` 文件，`stacks_base_url` 为 `http://stacks:7788` |
| 下载超时/卡住 | 设置 HTTP 代理；确认 flaresolverr 容器运行中 |
| OCR 失败 | `docker compose logs app \| grep -i ocr` 查看日志 |
| PaddleOCR 不工作 | `docker compose logs app \| grep -i paddle` 确认检测 |
| LLM OCR 无响应 | 确认 LM Studio/Ollama 已启动且端点可达 |
| 端口冲突 | 修改 compose 中 `ports` 映射，如 `9000:8000` |
| 国内拉取慢 | 配置镜像加速器或使用 ACR |
| 磁盘不足 | 清理 `tmp/` 目录 |
| 容器启动后秒退 | `docker compose logs` 查看错误日志 |

---

## 📄 许可证

MIT © Ebook PDF Downloader — 基于 [Callioper/ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) v1.3.0
