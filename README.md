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
| `config_data` (volume) | 应用配置文件 + 任务记录（`/app/data/`） |

## 配置 Stacks

放入 SQLite 数据库到 `./ebook-db/` 目录，用 `--profile full` 启动，然后在设置页配置：

- `stacks_base_url`: `http://stacks:7788`

## 配置 FlareSolverr

启用 FlareSolverr 后安娜的档案下载可绕过 Cloudflare 验证。用 `--profile full` 启动。

- `flaresolverr_port`: `8191`

## 手动构建

```bash
docker compose build
```

## 配置指南

首次启动后访问 `http://<your-ip>:8000`，点击右上角设置图标进入配置页：

- **下载来源**：Z-Library 需要 `zlib_email` / `zlib_password`；Anna's Archive 需要 `aa_membership_key`
- **OCR 设置**：默认 Tesseract，可在设置页切换 PaddleOCR 或 LLM OCR
- **Stacks**：如需本地检索引擎，确保 `stacks_base_url` 设为 `http://stacks:7788`
- **FlareSolverr**：如需 CF 绕过，确保 FlareSolverr 已启动（`--profile full`），端口 8191

## 系统要求

| 项目 | 最低 | 推荐 |
|------|------|------|
| Docker | 20.10+ | 24+ |
| 内存 | 4 GB | 8 GB+ |
| 磁盘 | 5 GB（含镜像） | 20 GB+（含下载文件） |
| CPU 架构 | amd64 / arm64 | — |

## 更改端口

编辑 `docker-compose.yml` 中 `ports` 映射：

```yaml
ports:
  - "9000:8000"  # 主机9000 → 容器8000
```

## 故障排查

| 问题 | 解决 |
|------|------|
| OCR 失败 | 检查日志 `docker compose logs app`，确认 Tesseract/PaddleOCR 已启用 |
| 下载超时 | 检查代理设置 `http_proxy`，或启用 FlareSolverr |
| Stacks 搜不到 | 确认 `./ebook-db/` 有 `*.db` 文件，`stacks_base_url` 设为 `http://stacks:7788` |
| 端口冲突 | 修改 `docker-compose.yml` 中 `ports` 映射 |
| 升级后功能不变 | 确认 `config_data` volume 正常挂载到 `/app/data`
