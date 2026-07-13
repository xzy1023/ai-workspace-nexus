# 项目级本地化集成脚手架 (Project Integration Scaffold)

本目录提供了一套标准的项目级本地化集成配置模板。当您在具体业务项目（例如 `MpMES`）中与 Antigravity 协作时，可以将本配置中的 `.agents/` 目录复制放入业务项目的根目录下，用以注入当前项目的专属业务知识与编码规约。

---

## 💡 MpMES 实战经验反哺 (Best Practices)

在大型项目（如 `MpMES`）的迭代中，我们沉淀出了以下三项核心的本地化配置最佳实践，用以保证开发的高效与 Token 消耗的最小化：

1. **静态参考文件移出 `skills/`，统一存入 `docs/`**
   * *原则*：诸如详细的数据字典 (Database Schema)、大量的 API 返回报文样例、冗长的业务规则说明等静态文件，**严禁**作为运行规则载入。
   * *原因*：若作为 Active Skill 加载，这些庞大的文件会在每次对话时被强行塞入 AI 的上下文，极易造成 Token 浪费与上下文截断。应将它们扁平化地存放在 `docs/` 目录下，由 AI 在需要时通过 `view_file` 按需查阅。
2. **区分 Rules (被动规则) 与 Skills (主动技能)**
   * *原则*：
     * **Rules (被动规则)**：用于存放“必须遵守”的静态编码约束和风格限制，采用扁平的 Markdown 文件存放在 `.agents/rules/` 下。
     * **Skills (主动技能)**：用于开发特定的流程化动作，采用独立目录包存放在 `.agents/skills/` 下，且核心指令命名为 `SKILL.md`。
3. **高精度的 YAML Frontmatter `description` 配置**
   * *原则*：每一个 Rule 或 Skill 文件的 description 描述必须极其精准，明确指出该规则适用的**具体项目分层、文件路径、文件类型后缀**（如 `Use when modifying .razor or .razor.cs files in Project.UI...`）。
   * *原因*：AI 引擎在装载上下文时，是依赖此描述来进行条件式动态加载的。描述越精准，越能确保“写前端时不加载后端规则，写后端时不加载 UI 规则”，实现零浪费的上下文装载。

---

## 📂 推荐的双层知识体系结构 (Two-Layer Knowledge System)

为了最大化开发效率并控制 token 消耗（防止大模型每次请求都全量加载冗长的参考信息），我们强烈推荐采用以下**双层隔离结构**：

```
业务项目根目录/
  ├── .agents/                         # 第一层：执行规则层 (AI 原生自动加载的硬约束)
  │     ├── rules/                     # 被动约束规范 (扁平 Markdown)
  │     │     ├── project-rules.md     # [必选] 本地专有的工程/编码边界与层级依赖限制
  │     │     ├── background-tasks.md  # [可选] 针对特定后台服务或数据流的编码约束
  │     │     └── ui-development.md    # [可选] 针对特定前端框架、UI 组件和交互的约束
  │     │
  │     └── skills/                    # 主动步骤技能 (目录包结构)
  │           └── feature-builder/     
  │                 └── SKILL.md       # [可选] 引导层级构建开发的主动技能指令
  │
  ├── docs/                            # 第二层：参考知识层 (AI 仅在需要时通过文件浏览读取)
  │     ├── README.md                  # 扁平化文档入口索引
  │     ├── architecture/              # 架构参考 (如 PATTERN_BACKEND.md)
  │     ├── database/                  # 数据库字典 (如 SCHEMA_MES.md) — 严禁作为 skill 自动加载
  │     └── planning/                  # 任务排期与 Backlog
```

---

## 🧭 两层知识体系的划分原则

### 1. 执行规则层 (`.agents/`)
* **放什么**：大模型编写代码时**必须严格遵守**的格式、命名约定、依赖流向红线、特定框架规约或失败处理模式。
* **核心要求**：
  * **按领域拆分 (Domain Splitting)**：不要把所有规则塞进单个文件。应拆分为 `project-rules.md`、`ui-development.md` 等，减少不相关的上下文加载。
  * **精准的 Trigger 描述**：每个 rule/skill 的 YAML Frontmatter 中，其 `description` 必须精确到具体的目标项目层或文件类型（例如 `Use when modifying .razor files...`），从而实现**零浪费的按需加载**。
  * **避免与全局规则重复**：全局 `ai-workspace-nexus` 已经规定了通用的 C# async/IDisposable 最佳实践、xUnit/NSubstitute 基础、TDD 流程和调试三击升级协议。本地规则中**仅保留项目特有的差异和补充**。

### 2. 参考知识层 (`docs/`)
* **放什么**：静态信息。包括大型数据库字典 (Schema)、全量业务规则 (如 BR-01 到 BR-99)、架构拓扑图、接口返回字段示例等。
* **核心要求**：这些内容体积庞大，如果放入 `.agents/` 会在每次请求时被塞入 AI 的上下文，造成极大的 Token 浪费。应该把它们存为 `docs/` 下的普通 markdown，并在 rules 中写入链接或在开发时由 AI 按需浏览。

---

## 📝 核心文件编写模板指引

### 1. `.agents/rules/project-rules.md`
定义项目级别的编码红线与架构依赖方向限制。需剔除通用的语言规范，只留下本项目专有的依赖约束与规约。

### 2. `.agents/rules/ui-development.md` & `background-tasks.md`
按需创建的领域专属被动规则文件。利用 YAML 描述中的 `description` 过滤机制，使 UI 规则只在编写前端代码时加载，后台规则只在编写服务类时加载。

### 3. `.agents/skills/<skill-name>/SKILL.md`
对于具备多步骤流程性质、能够驱动子代理或自动执行脚本的主动功能，使用独立文件夹打包。

---

## 🚀 如何在业务项目中激活本地特化

1. 将本 `scaffold/.agents/` 目录复制到您的业务项目根目录下。
2. 根据项目的实际业务情况，删除或修改 `.agents/rules/` 下的各类业务知识 Markdown。
3. 创建 `docs/` 目录用于管理庞大的静态参考知识，并使用 `docs/README.md` 作为扁平索引。
4. 开启新会话时，Antigravity 会自动合并全局工程规约与本地特化规则，输出高质量的契约代码。
