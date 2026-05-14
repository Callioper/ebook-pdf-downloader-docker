# 📚 Ebook PDF Downloader (Docker)

[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100%2B-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)
[![OCR](https://img.shields.io/badge/OCR-PaddleOCR%20%7C%20Tesseract%20%7C%20LLM-orange?style=for-the-badge)](https://github.com/PaddlePaddle/PaddleOCR)
[![Platform](https://img.shields.io/badge/Platform-amd64%20%7C%20arm64-green?style=for-the-badge)](https://github.com/Callioper/ebook-pdf-downloader-docker)

> **Docker 镜像版** — 基于 [ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) v1.3.0，全 OCR 引擎内置（Tesseract + PaddleOCR + Surya 版面检测），`docker compose up -d` 一键部署。

> **国内用户**：使用阿里云 ACR 镜像（`registry.cn-shanghai.aliyuncs.com`），无需代理，秒级拉取。

---

## 🚀 快速启动

```bash
# 国内用户（推荐，阿里云 ACR）
docker pull crpi-v5h0koewouiw970u.cn-shanghai.personal.cr.aliyuncs.com/ebook-pdf-downloader-docker/ebook-pdf-downloader-docker:latest

# 国际用户（GitHub Container Registry）
docker pull ghcr.io/callioper/ebook-pdf-downloader-docker:latest
```

或本地构建：
```bash
git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git
cd ebook-pdf-downloader-docker
docker compose up -d
```

- **🔍 多源检索**: 本地 SQLite 电子书数据库（EbookDatabase）+ Anna's Archive + Z-Library eAPI + LibGen 回退
- **📥 智能下载**: Stacks 队列管理 AA 下载，FlareSolverr 绕过 Cloudflare/DDoS-Guard，Z-Library 邮箱登录直达
- **⚙️ OCR 三引擎内置**: Tesseract（默认，CPU 轻量）、PaddleOCR（CPU 推理，中文主力 ~24min/217页）、LLM OCR（Surya 版面检测 + 视觉大模型逐框识别）
- **📑 AI 智能目录**: AI Vision 页面选择 + 偏移量对齐确认，自动注入 PDF 层级书签
- **📄 PDF 预览**: 任务详情页右侧实时 PDF 预览，翻页 + 页码跳转，自适应窗口
- **📝 文件名模板**: `{title}_{author}_{isbn}_{year}` 等 8 个元数据字段自定义
- **⏯️ 任务控制**: 暂停/恢复/重试/取消，WebSocket 实时进度推送
- **🎨 现代 Web UI**: React 18 + TypeScript + Tailwind CSS，深色模式自适应（06:00-18:00 浅色）
- **📦 PDF 压缩**: OCR 后黑白二值化压缩（pikepdf + FlateDecode），压缩率 78%-86%，文字层完整保留

---

## 🏗️ 架构

```
docker-compose.yml
├── app (自建镜像)
│   ├── Python 3.11 + FastAPI 后端（uvicorn）
│   ├── React/Vite 前端（构建产物）
│   ├── Tesseract OCR + chi_sim/eng 语言包
│   ├── PaddleOCR CPU 版（独立 venv，paddlepaddle + paddlex）
│   └── local-llm-pdf-ocr（Surya 检测 + LLM 识别 + SimSun CJK 字体嵌入）
├── stacks (ebook searcher, --profile full, 端口 7788)
└── flaresolverr (Cloudflare 绕过, --profile full, 端口 8191)
```

### 管道流程

```
搜索 → 获取 ISBN/元数据 → 下载 PDF → 转换封装 → OCR 识别 → 智能目录 → 完成输出
                                              ↑              ↑
                                       确认对话框（可选）   确认对话框（可选）
```

---

## 🚀 安装指引

### 前置条件

| 组件 | 最低要求 | 推荐 | 安装方式 |
|------|:--:|:--:|------|
| **Docker** | 20.10+ | 24+ | [docs.docker.com](https://docs.docker.com/get-docker/) |
| **Docker Compose** | V2 | V2 | Docker Desktop 已内置；Linux 用 `docker compose` 插件 |
| **内存** | 4 GB | 8 GB+ | OCR 时 PaddleOCR 和 Surya 各占 500MB-1GB |
| **磁盘** | 10 GB | 50 GB+（含下载） | 镜像 ~2.5GB，PDF 下载额外占用 |
| **CPU 架构** | amd64 / arm64 | — | QNAP/Synology NAS ARM64 可用 |
| **数据库文件** | — | 推荐 | 见下方"配置数据库" |

> **国内环境**：配置 Docker 镜像加速器。编辑 `/etc/docker/daemon.json`：
```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerhub.timeweb.cloud"
  ]
}
```
然后 `sudo systemctl restart docker`。

---

### 方式一：docker compose（推荐）

适用于有 git 的环境（Linux / macOS / Windows Git Bash）。

```bash
# 1. 克隆仓库
git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git
cd ebook-pdf-downloader-docker

# 2. 创建数据目录
mkdir -p downloads finished tmp ebook-db

# 3. 构建并启动核心服务（下载 + OCR + 书签）
docker compose up -d

# 4. 如需 Stacks 检索引擎 + FlareSolverr：
docker compose --profile full up -d
```

访问 `http://<你的IP>:8000`（本机 `http://localhost:8000`）。

---

### 方式二：已有 docker-compose.yml

如果你已有 `docker-compose.yml`，只需项目目录：

```bash
# 1. 创建目录结构
mkdir -p ebook-pdf-downloader-docker/{downloads,finished,tmp,ebook-db}
cd ebook-pdf-downloader-docker

# 2. 下载 compose 文件
curl -O https://raw.githubusercontent.com/Callioper/ebook-pdf-downloader-docker/master/docker-compose.yml

# 3. 构建并启动
docker compose up -d
```

---

### 方式三：预构建镜像（跳过编译）

```bash
# 拉取预构建镜像
docker pull ghcr.io/callioper/ebook-pdf-downloader-docker:latest

# 用预构建镜像启动（不编译，直接拉取）
mkdir -p {downloads,finished,tmp,ebook-db}
curl -O https://raw.githubusercontent.com/Callioper/ebook-pdf-downloader-docker/master/docker-compose.yml
docker compose up -d
```

---

### NAS 部署

#### QNAP Container Station

1. Container Station → 创建 → 创建应用程序
2. 粘贴 `docker-compose.yml`：
```yaml
services:
  app:
    image: callioper/ebook-pdf-downloader-docker:latest
    container_name: book-downloader
    ports:
      - "8000:8000"
    volumes:
      - /share/Public/ebook/downloads:/downloads
      - /share/Public/ebook/finished:/finished
      - /share/Public/ebook/tmp:/tmp/bdw
      - /share/Public/ebook/ebook-db:/data
      - ebook_config:/app/data
    restart: unless-stopped

  stacks:
    image: ghcr.io/callioper/book-searcher:latest
    container_name: book-searcher
    ports:
      - "7788:7788"
    volumes:
      - /share/Public/ebook/ebook-db:/data
    restart: unless-stopped
    profiles:
      - full

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    ports:
      - "8191:8191"
    environment:
      - LOG_LEVEL=info
    restart: unless-stopped
    profiles:
      - full

volumes:
  ebook_config:
```
3. 前端创建共享文件夹 `ebook`，子目录 `downloads` / `finished` / `tmp` / `ebook-db`
4. 放入 SQLite 数据库到 `ebook-db/`
5. 创建 → 等构建完成 → 访问 `http://<NAS_IP>:8000`

#### Synology Container Manager

1. Container Manager → 项目 → 新增
2. 项目名称：`ebook-pdf-downloader`
3. 来源：创建 docker-compose.yml（粘贴上面 QNAP 版的 compose 内容）
4. 调整 `volumes` 映射为 Synology 路径：
```yaml
volumes:
  - /volume1/docker/ebook/downloads:/downloads
  - /volume1/docker/ebook/finished:/finished
  - /volume1/docker/ebook/tmp:/tmp/bdw
  - /volume1/docker/ebook/ebook-db:/data
```
5. 下一步 → 完成

---

### 📂 文件夹映射详解

| 容器内路径 | 用途 | 映射建议 | 必需 |
|---|---|---|---|
| `/downloads` | 下载的 PDF 临时文件 | `./downloads:/downloads` | 推荐 |
| `/finished` | OCR 完成的最终 PDF | `./finished:/finished` | 推荐 |
| `/tmp/bdw` | 管道处理临时文件（图片、中间产物） | `./tmp:/tmp/bdw` | 推荐 |
| `/app/data` | 配置文件 + 任务记录 | `ebook_config:/app/data` (volume) | 必须 |
| `/data`（Stacks 容器内） | SQLite 电子书数据库 | `./ebook-db:/data` | 按需 |

**映射示例 (Linux/macOS)**：
```yaml
volumes:
  - ebook_config:/app/data           # 配置持久化（named volume，自动管理）
  - /mnt/data/ebooks/downloads:/downloads   # 下载目录
  - /mnt/data/ebooks/finished:/finished     # 成品目录
  - /mnt/data/ebooks/tmp:/tmp/bdw           # 临时文件
  - /mnt/data/ebooks/db:/data               # 数据库（给 Stacks 服务）
```

**映射示例 (Windows Docker Desktop)**：
```yaml
volumes:
  - ebook_config:/app/data
  - D:/ebooks/downloads:/downloads
  - D:/ebooks/finished:/finished
  - D:/ebooks/tmp:/tmp/bdw
  - D:/ebooks/db:/data
```

> **注意**：Windows 路径需在 Docker Desktop → Settings → Resources → File Sharing 中添加对应盘符。

---

### 📚 配置数据库

#### 获取数据库文件

从 [EbookDatabase](https://github.com/Hellohistory/EbookDatabase) 下载：

| 文件 | 大小 | 说明 |
|------|:--:|------|
| `DX_2.0-5.0.db` | ~1.7 GB | ISBN 2.0-5.0 范围（推荐，覆盖绝大多数中文书） |
| `DX_6.0.db` | ~300 MB | ISBN 6.0 范围（补充） |

#### 放入数据库

```bash
# 下载后放到 ebook-db 目录
cp DX_2.0-5.0.db ./ebook-db/
cp DX_6.0.db ./ebook-db/

# 如果用 --profile full 启动，Stacks 自动扫描 /data 目录
docker compose --profile full up -d
```

#### 配置 Stacks 地址

启动后进入 Web UI → 设置 → 来源：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `stacks_base_url` | `http://stacks:7788` | 容器间通信用服务名 |
| `stacks_api_key` | （可选） | Stacks API 密钥 |

> 如不使用 Stacks（无 `--profile full`），应用仍可通过 Z-Library 和 Anna's Archive 直接搜索下载。

---

### ⚙️ 配置指南

启动后访问 `http://<IP>:8000`，右上角 ⚙️ 进入设置页。

#### 必配项

| 配置项 | 说明 | 示例 |
|--------|------|------|
| **Z-Library** | | |
| `zlib_email` | Z-Library 邮箱 | `user@example.com` |
| `zlib_password` | Z-Library 密码 | — |
| **Anna's Archive** | | |
| `aa_membership_key` | AA 会员密钥（加快下载） | 可选 |

#### OCR 配置

| 配置项 | 默认值 | 说明 |
|--------|:--:|------|
| `ocr_engine` | `tesseract` | `tesseract` / `paddleocr` / `llm_ocr` |
| `ocr_jobs` | `4` | 并发线程数，内存不足降为 `1` |
| `ocr_languages` | `chi_sim+eng` | Tesseract 语言包 |
| `ocr_timeout` | `7200` | 单任务最大 OCR 秒数 |

**切换 PaddleOCR**：设置页 OCR 面板 → 引擎选 `paddleocr` → 保存即可。PaddleOCR 已内置在镜像中，无需额外安装。

**配置 LLM OCR**：需同网络另一台设备运行 LM Studio / Ollama。
1. 启动 LM Studio → 加载 `qwen3-vl-4b-instruct`（或其他视觉模型）
2. 设置页填入：
   - `llm_ocr_endpoint`: `http://192.168.1.x:1234/v1`
   - `llm_ocr_model`: `qwen3-vl-4b-instruct`
   - OCR 引擎选 `llm_ocr`

#### 下载来源配置

| 配置项 | 说明 | 值 |
|--------|------|-----|
| `http_proxy` | HTTP 代理（国内访问外网） | `http://127.0.0.1:7890` |
| `stacks_base_url` | Stacks 服务地址 | `http://stacks:7788` |
| `flaresolverr_port` | FlareSolverr 端口 | `8191` |

#### AI Vision 智能目录配置

| 配置项 | 说明 |
|--------|------|
| `ai_vision_enabled` | 启用 AI 目录提取 |
| `ai_vision_provider` | 提供商：`openai_compatible` / `ollama` / `lm_studio` / `doubao` / `zhipu` |
| `ai_vision_endpoint` | API 端点 |
| `ai_vision_model` | 模型名称 |
| `ai_vision_api_key` | API 密钥（本地服务可留空） |

---

## 📊 OCR 引擎对比

| 引擎 | 217 页耗时 | 中文精度 | 内存占用 | 场景 |
|------|:--:|:--:|:--:|------|
| **Tesseract** | ~15 分钟 | ★★★ | 低 (~300MB) | 英文/轻量 |
| **PaddleOCR** | ~24 分钟 | ★★★★★ | 中 (~800MB) | 中文主力 |
| **LLM OCR** | 取决于 API | ★★★★ | CPU 版面检测 ~2GB | 高质量 + 外部推理 |

> PaddleOCR 启动时自动检测 venv。LLM OCR Surya 版面检测在 CPU 上运行，每页约 30s-2min。

---

## 💾 数据持久化详情

### 配置文件

存储在 named volume `ebook_config`，挂载到 `/app/data`：
- `config.json`：应用配置（下载来源、OCR 设置、AI 端点等）
- `tasks.json`：任务列表和状态
- `app.log`：应用日志

```bash
# 备份配置
docker run --rm -v ebook_config:/data alpine tar czf - -C /data . > ebook-config-backup.tar.gz

# 恢复配置
docker run --rm -v ebook_config:/data -v $PWD:/backup alpine tar xzf /backup/ebook-config-backup.tar.gz -C /data
```

### 下载文件

```bash
# 成品 PDF 在 ./finished/
ls ./finished/

# 下载中的 PDF 在 ./downloads/
ls ./downloads/

# 临时文件在 ./tmp/，可定期清理
rm -rf ./tmp/*
```

---

## 🔄 升级

```bash
cd ebook-pdf-downloader-docker

# 拉取最新代码
git pull

# 重新构建并重启
docker compose build --no-cache
docker compose up -d

# 或使用预构建镜像
docker compose pull app
docker compose up -d
```

> 升级后 `config_data` volume 中的配置文件**保留不变**，无需重新配置。

---

## 🔧 高级配置

### 更改端口

编辑 `docker-compose.yml`：
```yaml
services:
  app:
    ports:
      - "9000:8000"  # 宿主机 9000 → 容器 8000
```

### 限制内存

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          memory: 6G
```

### 仅启动核心服务（无 Stacks/FlareSolverr）

```bash
docker compose up -d          # 只启动 app 服务
```

此时 Z-Library 下载和 Anna's Archive 直连下载仍可用。

### 全功能模式

```bash
docker compose --profile full up -d   # app + stacks + flaresolverr
```

---

## 📡 API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/search` | 搜索电子书（query/isbn/ss_code） |
| POST | `/api/v1/tasks` | 创建下载任务 |
| POST | `/api/v1/tasks/{id}/start` | 启动 7 步处理管道 |
| POST | `/api/v1/tasks/{id}/pause` | 暂停任务 |
| POST | `/api/v1/tasks/{id}/resume` | 恢复任务 |
| POST | `/api/v1/tasks/{id}/cancel` | 取消任务 |
| POST | `/api/v1/tasks/{id}/retry` | 重试失败任务 |
| DELETE | `/api/v1/tasks/completed` | 清除已完成任务 |
| GET | `/api/v1/tasks/{id}` | 查询任务详情 |
| GET/POST | `/api/v1/config` | 读取/更新配置 |
| GET | `/api/v1/health` | 健康检查（Docker Compose `depends_on` 可用） |
| WS | `/api/v1/ws` | WebSocket 实时进度推送 |
| GET | `/api/v1/system-status` | 系统组件状态（Tesseract/PaddleOCR/LLM OCR 可用性） |

---

## 🛠️ 故障排查

### 启动问题

| 现象 | 解决 |
|------|------|
| **端口 8000 被占用** | 修改 `docker-compose.yml` 的 `ports` 映射，或终止占用进程 |
| **容器启动后秒退** | `docker compose logs app` 查看错误日志 |
| **首次构建失败** | 检查网络（国内需代理或镜像加速器），重试 `docker compose build --no-cache` |
| **内存不足构建失败** | Docker Desktop → Settings → Resources → 增加内存至 6GB+ |

### OCR 问题

| 现象 | 解决 |
|------|------|
| **Tesseract 不识别** | `docker compose logs app \| grep -i tesseract` 检查检测状态 |
| **PaddleOCR 不工作** | `docker compose logs app \| grep -i paddle` 确认 venv 检测成功 |
| **LLM OCR 无响应** | 1) 确认 LM Studio/Ollama 已启动 2) `curl http://192.168.x.x:1234/v1/models` 验证 3) 设置页端点是否正确 |
| **OCR 乱码** | 设置页检查 `ocr_languages` 为 `chi_sim+eng`；推荐用 PaddleOCR |
| **OCR 超时** | 增大 `ocr_timeout`（秒），默认 7200 |

### 下载问题

| 现象 | 解决 |
|------|------|
| **下载超时/卡住** | 1) 设置 HTTP 代理 2) 启用 FlareSolverr (`--profile full`) |
| **Z-Library 搜不到** | 确认 `zlib_email`/`zlib_password` 已填且正确 |
| **AA 下载慢** | 填 `aa_membership_key`（AA 会员密钥） |
| **Stacks 无结果** | 1) `docker compose --profile full ps` 看 stacks 是否 running 2) `./ebook-db/` 有 `*.db` 文件 3) 设置页 `stacks_base_url: http://stacks:7788` |

### 配置/数据问题

| 现象 | 解决 |
|------|------|
| **升级后配置丢失** | 检查 `config_data` volume 是否正常：`docker volume inspect ebook-pdf-downloader-docker_ebook_config` |
| **下载文件找不到** | 检查 volume 映射路径是否正确；`docker exec book-downloader ls /finished` |
| **磁盘空间不足** | 清理 `./tmp/` 和 `./downloads/`；OCR 成品在 `./finished/` |

### 查看日志

```bash
# 实时日志
docker compose logs -f app

# 最近 100 行
docker compose logs --tail 100 app

# 进入容器调试
docker exec -it book-downloader /bin/bash
```

---

## 📁 项目结构

```
ebook-pdf-downloader-docker/
├── Dockerfile              # 多阶段构建（Node 20 编译前端 + Python 3.11 运行后端）
├── docker-compose.yml       # 服务编排（app + stacks + flaresolverr）
├── .dockerignore            # 排除 venv/node_modules/db 文件等
├── backend/                 # FastAPI 后端
│   ├── main.py              # 入口，uvicorn 启动，SPA 静态文件挂载
│   ├── config.py            # 配置管理（config.json 持久化）
│   ├── platform_utils.py    # 跨平台工具（is_docker / 进程管理 / Tesseract 检测）
│   ├── version.py           # 版本号 VERSION="1.3.0"
│   ├── search_engine.py     # SQLite 双库并行检索引擎
│   ├── task_store.py        # 任务内存字典 + JSON 持久化
│   ├── ws_manager.py        # WebSocket 连接/订阅管理
│   ├── api/                 # REST API 路由
│   │   ├── search.py        # 搜索（本地 DB + AA + ZL）、安装更新、OCR 检测
│   │   ├── tasks.py         # 任务 CRUD + 控制（start/pause/resume/cancel/retry）
│   │   ├── ws.py            # WebSocket 端点
│   │   └── toc.py           # 目录/书签 API（PDF 渲染、AI 提取、注入）
│   ├── engine/              # 核心处理引擎
│   │   ├── pipeline.py      # 7 步管道编排：metadata → ISBN → download → convert → OCR → bookmark → finalize
│   │   ├── aa_downloader.py # Anna's Archive 搜索 + 元数据
│   │   ├── zlib_downloader.py # Z-Library curl_cffi eAPI 下载
│   │   ├── flaresolverr.py  # FlareSolverr 集成（进程管理 + 健康检查）
│   │   ├── pdf_bw_compress.py # PDF 黑白二值化压缩（pikepdf + Pillow）
│   │   ├── pdf_utils.py     # PDF 拆分/合并工具
│   │   ├── surya_detect.py  # Surya 版面检测 CLI 封装
│   │   ├── mineru_client.py # MinerU 在线 API 客户端
│   │   ├── paddleocr_online_client.py # PaddleOCR-Online API 客户端
│   │   └── filename_template.py # 文件名模板引擎
│   ├── addbookmark/         # 书签/目录模块
│   │   ├── ai_vision_toc.py # AI Vision 智能 TOC 提取
│   │   ├── bookmarkget.py   # 书葵网书签获取
│   │   ├── bookmark_merger.py # 三源书签合并
│   │   ├── bookmark_injector.py # PDF 书签注入
│   │   ├── bookmark_parser.py # 书签解析
│   │   └── bookmark_offset.py # 偏移量校正
│   ├── book_sources/        # 豆瓣等外部书源
│   ├── nlc/                 # NLC 国家图书馆元数据爬虫
│   ├── data/                # 数据库文件目录
│   ├── static/              # 预编译前端静态文件（回退用）
│   └── requirements.txt     # Python 依赖
├── frontend/                # React 18 + TypeScript + Tailwind CSS
│   └── src/
│       ├── pages/           # SearchPage / ResultsPage / TaskDetailPage / TaskListPage
│       ├── components/      # Layout / BookCard / ConfigSettings / TOCModal / PDFPageViewer / LogStream
│       ├── stores/          # Zustand 状态管理
│       └── utils/           # sound / statusBadge
└── README.md
```

---

## 🙏 致谢

| 项目 | 用途 |
|------|------|
| [ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) | 上游项目 |
| [stacks](https://github.com/zelestcarlyone/stacks) | Anna's Archive 下载架构 |
| [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) | Cloudflare 绕过 |
| [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) | PDF OCR 引擎 |
| [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) | 中文 OCR |
| [Surya](https://github.com/VikParuchuri/surya) | 文档版面检测 |
| [local-llm-pdf-ocr](https://github.com/ahnafnafee/local-llm-pdf-ocr) | LLM OCR 管道 |
| [EbookDatabase](https://github.com/Hellohistory/EbookDatabase) | 电子书元数据库 |

---

## 📄 许可证

MIT © Ebook PDF Downloader
