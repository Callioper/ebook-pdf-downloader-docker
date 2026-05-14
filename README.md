# 📚 Ebook PDF Downloader (Docker)

> **GitHub:** https://github.com/Callioper/ebook-pdf-downloader-docker

[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)
[![OCR](https://img.shields.io/badge/OCR-PaddleOCR%20%7C%20Tesseract%20%7C%20LLM-orange?style=for-the-badge)](https://github.com/PaddlePaddle/PaddleOCR)
[![Platform](https://img.shields.io/badge/Platform-amd64%20%7C%20arm64-green?style=for-the-badge)](https://github.com/Callioper/ebook-pdf-downloader-docker)

> 一键部署的电子书下载 / OCR / 智能目录 Docker 镜像。全引擎内置，支持 x86 和 ARM（群晖/威联通/绿联）。

---

## 镜像地址

| Registry | 适用 | 命令 |
|----------|------|------|
| **阿里云 ACR**（推荐） | 国内，秒级拉取 | `docker pull crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest` |
| **Docker Hub** | 通用 | `docker pull elevenforhp/ebook-pdf-downloader-docker:latest` |
| **GitHub GHCR** | 国际 | `docker pull ghcr.io/callioper/ebook-pdf-downloader-docker:latest` |

---

## 🚀 NAS 一键部署

### 群晖 (Synology)

**Container Manager (DSM 7.2+)：**

1. 打开 **Container Manager** → 项目 → **新增**
2. 项目名称：`ebook`
3. 来源：**创建 docker-compose.yml**，粘贴：

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

volumes:
  config_data:
```

4. **下一步** → **完成**，等待拉取镜像
5. 访问 `http://<NAS_IP>:8000`

> 如国内拉取慢，先配置镜像加速：Container Manager → 设置 → Registry → 添加 `https://docker.m.daocloud.io`

---

### 威联通 (QNAP)

**Container Station：**

1. Container Station → **创建** → **创建应用程序**
2. 粘贴 YAML，注意**修改路径**为 QNAP 格式：

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
      - ebook_config:/app/data
    restart: unless-stopped

volumes:
  ebook_config:
```

3. File Station → **Public** 中创建 `ebook` 文件夹，内含 `downloads` / `finished` / `tmp` 三个子文件夹
4. 创建 → 访问 `http://<NAS_IP>:8000`

> 拉取私有 ACR 仓库需先在 Container Station → 设置 → Registry → 添加 `crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com`，用户名 `yy981204`

---

### 绿联 (UGREEN)

**UGOS Pro Docker：**

1. 打开 **Docker** 应用 → 镜像 → 拉取 → 输入 `crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest`
2. 拉取完成后 → **容器** → 新增 → 选择该镜像
3. 配置：
   - 端口映射：`8000:8000`
   - 路径映射（根据你的存储池调整 `/volume1`）：

| 容器内路径 | 宿主机路径 |
|---|---|
| `/downloads` | `/volume1/docker/ebook/downloads` |
| `/finished` | `/volume1/docker/ebook/finished` |
| `/tmp/bdw` | `/volume1/docker/ebook/tmp` |
| `/db` | `/volume1/docker/ebook/db` |
| `/app/data` | 选"新增存储卷" → 名称 `config_data` |

4. 创建并启动 → 访问 `http://<NAS_IP>:8000`

---

## 🖥️ Docker Compose 通用部署

适用于任何已安装 Docker 的 Linux/macOS/Windows 环境。

### 方式一：预构建镜像（推荐，无需编译）

```bash
mkdir -p ebook/{downloads,finished,tmp} && cd ebook
docker pull crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest

# 创建 docker-compose.yml（不含 build，纯拉取启动）
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

volumes:
  config_data:
EOF

docker compose up -d
```

### 方式二：克隆仓库本地构建

```bash
git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git
cd ebook-pdf-downloader-docker
docker compose build   # 本地编译，约 15-30 分钟
docker compose up -d
```

> 首次构建需下载 ~3GB 依赖，建议用预构建镜像。

---

## ⚙️ 初始化配置

访问 `http://<NAS_IP>:8000`，右上角 ⚙️ 进入设置。

### 必配项

| 配置项 | 说明 |
|--------|------|
| `zlib_email` / `zlib_password` | Z-Library 账号（搜索和下载需要） |
| `http_proxy` | 代理地址（国内访问 Z-Library/AA 需要） |

### OCR 引擎

| 引擎 | 说明 |
|------|------|
| **Tesseract**（默认） | 零配置，中文+英文 |
| **PaddleOCR** | 已内置，设置页切换即可，中文效果好 |
| **LLM OCR** | 需同网运行 LM Studio/Ollama 加载视觉模型 |

### 选配：本地数据库检索

1. 从 [EbookDatabase](https://github.com/Hellohistory/EbookDatabase) 下载 `DX_2.0-5.0.db`
2. 放入 `./db/` 目录，容器自动识别
3. 设置页数据库路径已默认为 `/db`，无需修改

### 选配：Stacks + FlareSolverr（全功能下载）

如需 Anna's Archive 高速搜索和 Cloudflare 绕过，启动全服务：

```bash
# 下载 docker-compose.yml 后添加以下服务，或用仓库自带的 compose
docker compose --profile full up -d
```

或手动在 compose 中添加：

```yaml
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
```

然后设置页 `stacks_base_url` 填 `http://stacks:7788`。

---

## 📂 目录说明

| 路径 | 存储内容 |
|------|------|
| `./downloads/` | 下载中的 PDF |
| `./finished/` | OCR 完成的成品 |
| `./tmp/` | 临时文件（可定期清理） |
| `./db/` | SQLite 数据库文件（放入 `DX_*.db`） |
| `config_data` (volume) | 配置文件 + 任务记录 |

---

## 🔄 升级

```bash
docker compose pull app
docker compose up -d
```

配置和任务记录保留不变。

---

## 🛠️ 故障排查

| 问题 | 解决 |
|------|------|
| OCR 失败 | `docker compose logs app \| grep -i ocr` 查看日志 |
| 下载超时 | 设置 HTTP 代理，或启用 FlareSolverr |
| PaddleOCR 不工作 | `docker compose logs app \| grep -i paddle` 确认检测 |
| LLM OCR 无响应 | 确认 LM Studio/Ollama 已启动，端点可达 |
| 端口冲突 | 修改 `docker-compose.yml` 中 `ports: - "9000:8000"` |
| 国内拉取慢 | 配置镜像加速器或使用 ACR |
| 磁盘不足 | 清理 `./tmp/` 目录 |

---

## 📄 许可证

MIT © Ebook PDF Downloader — 基于 [Callioper/ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) v1.3.0
