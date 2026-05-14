# ebook-pdf-downloader (Docker 版)

> 基于 [Callioper/ebook-pdf-downloader](https://github.com/Callioper/ebook-pdf-downloader) v1.3.0

## 快速启动

```bash
# 仅启动核心应用（下载+OCR+书签）
docker compose up -d

# 启动全部服务（含 Stacks 检索引擎 + FlareSolverr CF绕过）
docker compose --profile full up -d
```

访问 `http://<your-ip>:8000`。

## 内置 OCR 引擎

| 引擎 | 说明 |
|------|------|
| **Tesseract**（默认） | 无需额外配置，中文+英文 |
| **PaddleOCR** | 自动检测，CPU 推理 |
| **LLM OCR** | 需配置外部 LLM API（Ollama / LM Studio / 豆包 / 智谱） |

## 升级

```bash
docker compose pull app
docker compose up -d
```

## 数据持久化

| 目录 | 内容 |
|------|------|
| `./downloads/` | 下载的 PDF 文件 |
| `./finished/` | OCR 完成品 |
| `./tmp/` | 临时文件 |
| `./ebook-db/` | Stacks 电子书数据库（需自行放入 *.db 文件） |
| `config_data` (volume) | 应用配置文件 + 任务记录 |

## 配置 Stacks

放入 SQLite 数据库到 `./ebook-db/` 目录，用 `--profile full` 启动，然后在设置页配置：

- `stacks_base_url`: `http://stacks:7788`

## 配置 FlareSolverr

启用 FlareSolverr 后安娜的档案下载可绕过 Cloudflare 验证。用 `--profile full` 启动。

- `flaresolverr_port`: `8191`

## 手动构建

```bash
docker build -t ebook-pdf-downloader-docker .
```
