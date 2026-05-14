# 📚 Ebook PDF Downloader (Docker)

[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100%2B-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)
[![OCR](https://img.shields.io/badge/OCR-PaddleOCR%20%7C%20Tesseract%20%7C%20LLM-orange?style=for-the-badge)](https://github.com/PaddlePaddle/PaddleOCR)
[![Platform](https://img.shields.io/badge/Platform-amd64%20%7C%20arm64-green?style=for-the-badge)](https://github.com/Callioper/ebook-pdf-downloader-docker)

> **Docker 镜像版** — 基于 [ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) v1.3.0 构建，全 OCR 引擎内置，`docker compose up -d` 一键部署。

---

## ✨ 功能特性

- **🔍 多源检索**: 本地 SQLite 数据库 + Anna's Archive + Z-Library eAPI
- **📥 智能下载**: FlareSolverr 绕过 Cloudflare，Z-Library 邮箱登录直达
- **⚙️ 全 OCR 引擎内置**: Tesseract（默认）、PaddleOCR（CPU 推理）、LLM OCR（需外部 LLM API）
- **📑 AI 智能目录**: AI Vision 页面选择 + 偏移量对齐，自动注入 PDF 层级书签
- **📄 PDF 预览**: 任务详情页实时 PDF 预览，翻页 + 页码跳转
- **📝 文件名模板**: `{title}_{author}_{isbn}` 等 8 个元数据字段
- **⏯️ 任务控制**: 暂停/恢复/重试/取消，WebSocket 实时进度
- **🎨 现代 Web UI**: React 18 + TypeScript + Tailwind CSS，深色模式自适应

---

## 🏗️ 架构

```
docker-compose.yml
├── app (自建镜像, ~2GB)
│   ├── Python 3.11 FastAPI 后端
│   ├── React/Vite 前端 (构建产物)
│   ├── Tesseract OCR + chi_sim/eng (apt)
│   ├── PaddleOCR CPU 版 (独立 venv)
│   └── local-llm-pdf-ocr (Surya 版面检测 + LLM 识别)
├── stacks (ebook searcher, --profile full)
└── flaresolverr (Cloudflare 绕过, --profile full)
```

---

## 🚀 安装指引

### 前置条件

| 组件 | 用途 | 安装方式 |
|------|------|----------|
| **Docker 20.10+** | 容器运行环境 | [docs.docker.com](https://docs.docker.com/get-docker/) |
| **Docker Compose V2** | 服务编排 | Docker Desktop 已内置 |
| **数据库文件** | 本地检索 | [EbookDatabase 下载文档](https://github.com/Hellohistory/EbookDatabase/blob/main/Markdown/%E6%95%B0%E6%8D%AE%E5%BA%93%E4%B8%8B%E8%BD%BD%E6%96%87%E6%A1%A3.md) |

> 下载 `DX_2.0-5.0.db` / `DX_6.0.db` 后放入 `./ebook-db/` 目录。用 `--profile full` 启动含 Stacks 服务后，在设置页配置 `stacks_base_url` 为 `http://stacks:7788`。

### 方式一：docker compose（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git
cd ebook-pdf-downloader-docker

# 2. 创建数据目录
mkdir -p downloads finished tmp ebook-db

# 3. （可选）放入 SQLite 数据库到 ebook-db/
#    下载 DX_2.0-5.0.db / DX_6.0.db 放入此目录

# 4. 构建并启动核心服务（下载 + OCR + 书签）
docker compose up -d

# 5. 若同时需要 Stacks 检索引擎 + FlareSolverr：
docker compose --profile full up -d
```

访问 `http://<your-ip>:8000`。

### 方式二：使用预构建镜像

```bash
# 拉取镜像
docker pull ghcr.io/callioper/ebook-pdf-downloader-docker:latest

# 下载 docker-compose.yml
curl -O https://raw.githubusercontent.com/Callioper/ebook-pdf-downloader-docker/master/docker-compose.yml

# 启动
docker compose up -d
```

### 方式三：手动构建

```bash
git clone https://github.com/Callioper/ebook-pdf-downloader-docker.git
cd ebook-pdf-downloader-docker
docker compose build   # 首次构建需 10-20 分钟
docker compose up -d
```

### NAS 部署（QNAP / Synology）

**QNAP Container Station：**
1. 打开 Container Station → 创建 → 创建应用程序
2. 粘贴 `docker-compose.yml` 内容
3. 调整 volume 映射路径（如 `/share/Public/downloads:/downloads`）
4. 创建

**Synology Container Manager：**
1. 打开 Container Manager → 项目 → 新增
2. 设置项目名称，选择 `docker-compose.yml` 文件
3. 下一步 → 完成

---

## ⚙️ 配置

启动后在 Web UI 右上角 **⚙️ 设置** 中配置，所有更改即时生效：

| 配置项 | 说明 | Docker 默认值 |
|--------|------|:--:|
| **数据库** | | |
| SQLite 数据库目录 | `DX_*.db` 所在路径 | - |
| **下载** | | |
| 下载目录 | 临时存放 | `/downloads` |
| 保存目录 | 最终输出 | `/finished` |
| 文件名模板 | `{title}_{author}` 等 8 字段 | `{title}` |
| **来源** | | |
| HTTP 代理 | 访问外网 | 可选 |
| Stacks 地址 | AA 下载服务器 | `http://localhost:7788` |
| Z-Library 邮箱/密码 | 自动搜索下载 | 可选 |
| AA 会员 Key | 高速下载 | 可选 |
| **OCR** | | |
| OCR 引擎 | `tesseract` / `paddleocr` / `llm_ocr` | `tesseract` |
| 并发线程 | 同时处理页数 | `4` |
| 识别语言 | Tesseract 语言包 | `chi_sim+eng` |
| LLM OCR 端点 | OpenAI 兼容 API | `http://127.0.0.1:1234/v1` |
| LLM OCR 模型 | 模型名称 | `qwen3-vl-4b-instruct` |
| PDF 压缩 | BW 二值化压缩 | 关闭 |
| **AI Vision TOC** | | |
| 端点/模型/Key | OpenAI/Anthropic 兼容 | 可选 |

> **LLM OCR 配置示例**：启动同网络的 LM Studio → 加载 `qwen3-vl-4b-instruct` → 设置页填入 `http://192.168.1.x:1234/v1` → 引擎选 `llm_ocr`。

---

## 📊 OCR 引擎对比

| 引擎 | 速度 | 中文准确度 | 资源占用 | 推荐场景 |
|------|------|-----------|---------|---------|
| **Tesseract** | ~15min / 217 页 | ★★★ | 低 CPU | 英文/轻量 |
| **PaddleOCR** | ~24min / 217 页 | ★★★★★ | 中 CPU | 中文主力 |
| **LLM OCR** | 取决于 API | ★★★★ | 外部推理 | 高质量需求 |

> PaddleOCR 已内置在镜像中，无需额外安装，在设置页切换引擎即可。  
> LLM OCR 需外部运行 LM Studio / Ollama 加载视觉模型。

---

## 💾 数据持久化

| 宿主机路径 | 容器路径 | 内容 |
|---|---|---|
| `./downloads/` | `/downloads` | 下载的 PDF 文件 |
| `./finished/` | `/finished` | OCR 完成品 |
| `./tmp/` | `/tmp/bdw` | 临时文件 |
| `./ebook-db/` | `/data`（Stacks 容器内） | SQLite 数据库 |
| `config_data` (volume) | `/app/data` | 配置文件 + 任务记录 |

---

## 🔧 Stacks + FlareSolverr

### 仅需核心功能
```bash
docker compose up -d
```
不启动 Stacks/FlareSolverr，使用 Z-Library / 本地 DB 下载。

### 全功能模式
```bash
docker compose --profile full up -d
```

启动后进入设置页配置：
- `stacks_base_url`: `http://stacks:7788`
- `flaresolverr_port`: `8191`

放入 SQLite 数据库到 `./ebook-db/` 目录，Stacks 自动扫描。

---

## 🔄 升级

```bash
# 拉取最新代码
git pull

# 重新构建并重启
docker compose build
docker compose up -d

# 或使用预构建镜像
docker compose pull app
docker compose up -d
```

> 升级后 config_data volume 中配置文件保留不变。

---

## 🔧 更改端口

编辑 `docker-compose.yml`：

```yaml
services:
  app:
    ports:
      - "9000:8000"  # 宿主机 9000 → 容器 8000
```

---

## 📡 API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/search` | 搜索电子书 |
| POST | `/api/v1/tasks` | 创建下载任务 |
| POST | `/api/v1/tasks/{id}/start` | 启动处理管道 |
| POST | `/api/v1/tasks/{id}/pause` | 暂停任务 |
| POST | `/api/v1/tasks/{id}/resume` | 恢复任务 |
| POST | `/api/v1/tasks/{id}/cancel` | 取消任务 |
| POST | `/api/v1/tasks/{id}/retry` | 重试失败任务 |
| GET/POST | `/api/v1/config` | 读取/更新配置 |
| GET | `/api/v1/health` | 健康检查 |
| WS | `/api/v1/ws` | WebSocket 实时进度 |

---

## 🛠️ 故障排查

| 问题 | 解决 |
|------|------|
| **OCR 失败** | `docker compose logs app` 查看日志；确认引擎已启用 |
| **下载超时/卡住** | 检查 HTTP 代理；启用 FlareSolverr (`--profile full`) |
| **Stacks 搜不到** | 确认 `./ebook-db/` 有 `*.db` 文件；确认 `stacks_base_url: http://stacks:7788` |
| **PaddleOCR 不工作** | `docker compose logs app \| grep -i paddle` 查看是否检测到 venv |
| **LLM OCR 无响应** | 检查 LM Studio/Ollama 端点可达；确认模型已加载 |
| **端口冲突** | 修改 `docker-compose.yml` 的 `ports` 映射 |
| **内存不足** | 增加 Docker 内存限制；降低 `ocr_jobs` 至 1 |
| **升级后功能不变** | `docker compose down` → `docker compose up -d` 强制重建 |
| **国内拉取镜像慢** | 配置 Docker 镜像加速器 (`/etc/docker/daemon.json` 加 `registry-mirrors`) |

---

## 📁 项目结构

```
ebook-pdf-downloader-docker/
├── Dockerfile              # 多阶段构建（Node + Python）
├── docker-compose.yml       # 服务编排（app + stacks + flaresolverr）
├── .dockerignore            # Docker 构建上下文排除
├── backend/                 # FastAPI 后端
│   ├── main.py              # 入口
│   ├── api/                 # REST API 路由
│   ├── engine/              # 核心引擎（pipeline/downloader/ocr）
│   ├── addbookmark/         # 书签/目录模块
│   └── requirements.txt     # Python 依赖
├── frontend/                # React 18 + TypeScript
│   └── src/                 # 页面/组件/状态
├── config.default.json      # 默认配置
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

---

## 📄 许可证

MIT © Ebook PDF Downloader
