# 公益链上像素画板 - 项目逻辑与实现方案

## 技术栈

- [foundry](https://getfoundry.sh/introduction/getting-started) 
- [solidity](https://docs.soliditylang.org/en/v0.8.30/)

需要部署到的区块链: 

### 可选的技术

- [openzeppelin](https://www.openzeppelin.com/open-source-stack#steps)

## 🎯 项目核心理念

基于 Monad 的高性能区块链网络，打造一个完全**免费**的公益性链上像素画板，让全球用户共同创作数字艺术品，同时为未来 NFT 化和收益分成建立公平的贡献记录系统。

## 🏗️ 核心设计逻辑

### 1. 免费机制设计
- **零费用参与**：用户只需支付网络 gas fee，无需向合约支付任何代币
- **纯公益性质**：合约不收取任何费用，完全开放给所有用户
- **高频交互友好**：依托 Monad 的低 gas 特性，用户可以频繁操作

### 2. 贡献记录系统
- **像素归属跟踪**：记录每个像素的最后修改者
- **用户贡献统计**：统计每个用户总共画过多少个像素
- **贡献比例计算**：为未来 NFT 收益分成提供准确的比例数据

### 3. 高效操作设计
- **单点绘制**：支持逐个像素精确绘制
- **批量绘制**：支持一次性绘制多个像素，大幅节省 gas
- **坐标系统**：提供二维坐标与一维索引的双向转换

## 🔧 关键技术实现

### 数据存储结构

```solidity
// 画板尺寸：100x100 = 10,000个像素
uint256 public constant CANVAS_WIDTH = 100;
uint256 public constant CANVAS_HEIGHT = 100;

// 核心数据结构
mapping(uint256 => uint8) public pixels;           // 像素颜色数据
mapping(uint256 => address) public pixelOwners;    // 像素归属记录
mapping(address => uint256[]) public userContributions; // 用户贡献列表
mapping(address => uint256) public userContributionCount; // 用户贡献计数
```

### 核心功能函数

#### 1. `drawPixel(x, y, color)` - 单点绘制
```solidity
function drawPixel(uint256 x, uint256 y, uint8 color) external
```
- **功能**：在指定坐标绘制单个像素
- **特点**：完全免费，只消耗 gas
- **逻辑**：自动记录贡献，更新像素归属

#### 2. `drawPixelsBatch(x[], y[], colors[])` - 批量绘制
```solidity
function drawPixelsBatch(uint256[] calldata x, uint256[] calldata y, uint8[] calldata colors) external
```
- **功能**：一次性绘制多个像素
- **优势**：大幅节省 gas，提升绘制效率
- **适用场景**：绘制复杂图案、批量填充区域

#### 3. `getUserContributionRatio(user)` - 贡献比例查询
```solidity
function getUserContributionRatio(address user) external view returns (uint256)
```
- **功能**：计算用户在整个画板中的贡献占比
- **返回值**：基点制（10000 = 100%）
- **用途**：NFT 收益分成计算的基础数据

### 事件系统

```solidity
event PixelChanged(address indexed artist, uint256 indexed pixelIndex, uint256 x, uint256 y, uint8 color);
event BatchPixelsChanged(address indexed artist, uint256[] pixelIndices, uint8[] colors);
```

- **实时监听**：前端可以实时监听像素变化
- **历史记录**：所有绘制行为永久记录在链上
- **数据同步**：支持多客户端实时同步画板状态

## 🎨 用户交互流程

### 基础绘制流程
1. 用户连接钱包到 dApp
2. 选择要绘制的坐标和颜色
3. 调用 `drawPixel` 或 `drawPixelsBatch` 函数
4. 支付 gas fee 完成交易
5. 像素立即更新，贡献记录自动保存

### 贡献查询流程
1. 查询个人总贡献：`getUserContributionCount(address)`
2. 查询贡献详情：`getUserContributions(address)`
3. 查询贡献比例：`getUserContributionRatio(address)`
4. 查询画板进度：`getCanvasProgress()`

## 🚀 技术优势

### 1. 高性能体验
- **低延迟**：依托 Monad 的高 TPS，操作几乎实时生效
- **低成本**：极低的 gas 费用，支持高频互动
- **高并发**：支持成千上万用户同时绘制

### 2. 公平记录
- **精确追踪**：每个像素的归属都有明确记录
- **透明计算**：贡献比例计算完全透明可验证
- **防篡改**：所有数据永久存储在区块链上

### 3. 扩展性设计
- **模块化架构**：便于后续功能扩展
- **NFT 就绪**：为 NFT 化预留了完整的数据基础
- **收益分成就绪**：可直接基于贡献比例进行收益分配

## 🎯 未来 NFT 分成机制

### 分成原理
1. **贡献量化**：基于用户绘制的像素数量
2. **比例计算**：`用户像素数 / 总绘制像素数 * 100%`
3. **收益分配**：按比例分配 NFT 销售收入

### 实现示例
```solidity
// 如果 NFT 卖了 100 ETH，用户 A 贡献了 2% 的像素
uint256 nftSalePrice = 100 ether;
uint256 userRatio = getUserContributionRatio(userA); // 返回 200 (2%)
uint256 userShare = (nftSalePrice * userRatio) / 10000; // 2 ETH
```

## 🌟 项目亮点

1. **完全去中心化**：无需中心化服务器，纯链上运行
2. **社区驱动**：每个像素都是社区协作的结果
3. **经济激励**：为未来收益分成建立公平机制
4. **技术创新**：展示 Monad 高性能区块链的能力
5. **艺术价值**：创造独一无二的链上集体艺术作品

## 🔮 发展路线图

### Phase 1: 基础画板 (当前)
- ✅ 免费绘制功能
- ✅ 贡献记录系统
- ✅ 批量操作优化

### Phase 2: 增强功能
- 🔄 更多颜色支持 (8-bit → 24-bit)
- 🔄 画板尺寸扩展
- 🔄 绘制工具增强（线条、形状）

### Phase 3: NFT 化
- 🔮 定期快照生成 NFT
- 🔮 收益分成智能合约
- 🔮 治理机制引入

### Phase 4: 生态扩展
- 🔮 多画板支持
- 🔮 主题画板竞赛
- 🔮 跨链桥接功能
