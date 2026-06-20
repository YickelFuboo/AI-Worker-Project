# 架构元素抽取

## 功能描述

结合代码仓设计文档和源码，自动抽取架构元素、接口及依赖关系。生成或更新 `elements_tree.yaml` 和各元素的规格文件、接口定义文件、依赖关系文件。

## 所属 Agent

架构逆向 Agent

## 适用场景

- 存量项目缺少架构文档，需要从代码反向构建架构视图
- 代码变更后需要更新架构元素描述
- 需要建立完整的架构元素-接口-依赖关系图谱

## 工作方式

### 执行步骤

1. **读取代码仓文档**：加载各代码仓的 `spec.md` 和 `design.md`，提取架构元素信息
2. **读取源码**：分析源码中的模块边界、接口定义（头文件、API 定义）、include/import 关系
3. **读取构建配置**：分析 CMakeLists.txt、Makefile、requirements.txt 等，提取组件间依赖
4. **元素识别**：从代码模块映射到架构元素（服务、组件、子系统）
5. **接口抽取**：从代码中提取接口定义（函数签名、消息格式、协议类型）
6. **依赖分析**：分析元素间的调用关系和外部系统依赖
7. **生成架构文档**：
   - 更新 `architectures/logic_view/elements_tree.yaml`
   - 生成各元素的 `spec.md`（定位、规格、质量属性、业务能力）
   - 生成 `interfaces.yaml`（对外提供的接口列表）
   - 生成 `dependencies.yaml`（依赖的外部接口列表）

### 注意事项

- 架构元素的识别粒度应一致，不遗漏不重复
- 接口定义必须包含完整的签名和语义说明
- 依赖关系需区分内部依赖（元素间）和外部依赖（外部系统/库）
- 参考 `knowledge/模板库/架构元素设计模板.md` 的格式

### 输出要求

- 更新 `architectures/logic_view/elements_tree.yaml`
- 输出各元素的 `spec.md`，严格按模板：`templates/element_spec_template.md`
- 输出 `interfaces.yaml`、`dependencies.yaml`（按工作空间 2.3 节定义的格式）
- 输出架构抽取报告：识别的元素列表、接口统计、依赖关系图（PlantUML）
