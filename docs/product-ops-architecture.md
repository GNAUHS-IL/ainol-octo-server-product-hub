# 产品运营架构

本仓库采用“产品反馈入口 + 源码知识库 + PRD/Review + 状态巡检”的轻量闭环。

## 组件

- GitHub issue：承接 Bug / Feature / Question / Review。
- `knowledge/`：沉淀源码可核验结论。
- `docs/source-audit/`：保存结构化源码索引。
- `prd/`：保存 What-only PRD 模板。
- `review/`：保存评审检查清单。
- `scripts/`：保存引用校验、issue 扫描和推送校验脚本。

## 运行原则

1. 目标仓库 `Mininglamp-OSS/octo-server` 只读。
2. 所有关键结论必须可追溯到源码路径和行号。
3. 反馈先分类，再进入 issue 状态流转。
4. PRD 只描述用户可见的 What，不写实现 How。
5. 无实质状态变化不做外部同步。


## 协作边界

- 产品运营负责人：入口、初判、源码问答、建单、PRD Review、最终状态仲裁、群内主回复。
- 需求管理员：PRD 草拟与按 Review 意见修改、引用材料整理、label 初检、巡检与异常提醒。
- 需求管理员不 Review 自己产出的 PRD；`status/reviewing` 由产品运营负责人处理。
- `status/blocked` 通常不要求需求管理员介入，除非产品运营负责人明确要求补充材料。

- 正式转人工和最终风险裁决由产品运营负责人负责；需求管理员只做风险提醒、脱敏事实和待确认问题整理。
