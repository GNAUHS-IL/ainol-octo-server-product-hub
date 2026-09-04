# 源码深挖总览

- Target repo: `Mininglamp-OSS/octo-server`
- Commit: `49dc9fd97b49c6c9bad9a0abaefb0b48241e9601`
- Last audit time: `2026-09-04T20:25:49+08:00`

## 全仓扫描结果

| 项 | 数量 | 文件 |
|---|---:|---|
| 全仓文件 | 2724 | `docs/source-audit/all-files.md` |
| `modules/` 目录 | 41 | `docs/source-audit/module-inventory.md` |
| 已注册模块 | 38 | `docs/source-audit/module-inventory.md` |
| 未注册模块目录 | 3 | `docs/source-audit/module-inventory.md` |
| API 路由静态扫描 | 625 | `docs/source-audit/api-route-index.md` |
| 错误码 | 461 | `docs/source-audit/error-code-index.md` |
| SQL migration | 202 | `docs/source-audit/sql-migration-index.md` |
| GitHub workflows | 17 | `docs/source-audit/workflow-index.md` |

## 未注册目录

- `botidentity`
- `cardtrust`
- `source`

## 九大知识库入口

- `knowledge/01-auth-identity.md`
- `knowledge/02-authorization-model.md`
- `knowledge/03-configs.md`
- `knowledge/04-modules.md`
- `knowledge/05-api-errors.md`
- `knowledge/06-im-control-plane.md`
- `knowledge/07-bot-agent.md`
- `knowledge/08-storage-dependencies.md`
- `knowledge/09-build-release.md`

## 使用原则

1. 先用九大知识库回答结论。
2. 需要完整清单时，查 `docs/source-audit/*-index.md`。
3. 所有强结论必须带 `来源: <相对路径>#Lx-Ly`。
4. 对静态扫描可能漏掉的动态注册/运行期行为，必须标记不确定并继续补查。
