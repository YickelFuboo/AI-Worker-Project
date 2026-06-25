# 逻辑流设计

## 功能描述

将架构变更细化为模块级的逻辑流程设计。定义关键流程的控制流、数据流、状态转换，使用 PlantUML 序列图和状态图描述模块间交互和内部状态机。

## 所属 Agent

实现设计 Agent

## 适用场景

- 架构变更说明完成后，需要细化到模块级设计
- 需要描述复杂业务逻辑的控制流和数据流
- 需要为编码实现提供精确的流程蓝图

## 工作方式

### 执行步骤

1. **读取架构变更说明**：理解架构层面的接口和元素变更
2. **读取代码仓设计**：加载相关代码仓的 `design.md` 和模块 `design.md`，理解现有实现
3. **读取领域知识**：参考 `knowledge/领域知识/` 中的常见模式和协议规范
4. **逻辑流设计**：绘制 PlantUML 序列图描述模块间交互，绘制状态图描述关键状态机
5. **数据流设计**：定义数据对象在流程中的转换和传递
6. **输出设计文档**：按模板输出到 `requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`

### 注意事项

- 序列图必须精确标注参与对象/模块、消息名称、参数
- 状态图必须覆盖所有状态、转换条件和动作
- 优先复用现有模块的接口和流程，减少不必要的重构
- 参考 skill 自带模板 `templates/implementation_design_template.md`

### 输出要求

- 输出路径：`requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`
- 严格按模板格式输出：`templates/implementation_design_template.md`
- 包含 PlantUML 序列图（模块间交互）、状态图（如有状态机）
- 包含核心数据对象定义和关键函数签名
