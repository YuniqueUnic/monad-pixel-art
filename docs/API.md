# PublicPixelArt 合约 API 文档

## 概述

`PublicPixelArt` 是一个基于 Monad 区块链的公益像素画板合约，允许用户免费绘制像素并记录贡献。

## 常量

### CANVAS_WIDTH
```solidity
uint256 public constant CANVAS_WIDTH = 100
```
- **描述**: 画板宽度（像素数）
- **值**: 100
- **类型**: `uint256`

### CANVAS_HEIGHT
```solidity
uint256 public constant CANVAS_HEIGHT = 100
```
- **描述**: 画板高度（像素数）
- **值**: 100
- **类型**: `uint256`

### TOTAL_PIXELS
```solidity
uint256 public constant TOTAL_PIXELS = 10000
```
- **描述**: 画板总像素数
- **值**: 10000 (100 × 100)
- **类型**: `uint256`

## 状态变量

### pixels
```solidity
mapping(uint256 => uint8) public pixels
```
- **描述**: 像素颜色数据存储
- **键**: 像素索引（0-9999）
- **值**: 颜色值（0-255）
- **访问权限**: public

### pixelOwners
```solidity
mapping(uint256 => address) public pixelOwners
```
- **描述**: 像素所有者记录
- **键**: 像素索引（0-9999）
- **值**: 所有者地址
- **访问权限**: public

### userContributions
```solidity
mapping(address => uint256[]) public userContributions
```
- **描述**: 用户贡献的像素索引列表
- **键**: 用户地址
- **值**: 像素索引数组
- **访问权限**: public

### userContributionCount
```solidity
mapping(address => uint256) public userContributionCount
```
- **描述**: 用户贡献计数
- **键**: 用户地址
- **值**: 贡献的像素数量
- **访问权限**: public

### totalDraws
```solidity
uint256 public totalDraws = 0
```
- **描述**: 总绘制次数
- **初始值**: 0
- **访问权限**: public

### uniqueContributors
```solidity
uint256 public uniqueContributors = 0
```
- **描述**: 独立贡献者数量
- **初始值**: 0
- **访问权限**: public

## 函数

### coordsToIndex
```solidity
function coordsToIndex(uint256 x, uint256 y) public pure returns (uint256)
```
- **描述**: 将二维坐标转换为一维索引
- **参数**:
  - `x`: x坐标（必须 < CANVAS_WIDTH）
  - `y`: y坐标（必须 < CANVAS_HEIGHT）
- **返回值**: 一维索引
- **修饰符**: `pure`
- **错误**: 
  - "X coordinate out of bounds" - x坐标超出范围
  - "Y coordinate out of bounds" - y坐标超出范围

### indexToCoords
```solidity
function indexToCoords(uint256 index) public pure returns (uint256 x, uint256 y)
```
- **描述**: 将一维索引转换为二维坐标
- **参数**:
  - `index`: 一维索引（必须 < TOTAL_PIXELS）
- **返回值**: 
  - `x`: x坐标
  - `y`: y坐标
- **修饰符**: `pure`
- **错误**: "Index out of bounds" - 索引超出范围

### drawPixel
```solidity
function drawPixel(uint256 x, uint256 y, uint8 color) external
```
- **描述**: 绘制单个像素
- **参数**:
  - `x`: x坐标（0-99）
  - `y`: y坐标（0-99）
  - `color`: 颜色值（0-255）
- **修饰符**: `external`
- **事件**: 触发 `PixelChanged` 事件
- **错误**: 
  - "X coordinate out of bounds" - x坐标超出范围
  - "Y coordinate out of bounds" - y坐标超出范围
  - "Color value must be 0-255" - 颜色值超出范围

### drawPixelsBatch
```solidity
function drawPixelsBatch(
    uint256[] calldata x, 
    uint256[] calldata y, 
    uint8[] calldata colors
) external
```
- **描述**: 批量绘制多个像素
- **参数**:
  - `x`: x坐标数组
  - `y`: y坐标数组
  - `colors`: 颜色值数组
- **要求**:
  - 所有数组长度必须相同
  - 数组长度 > 0
  - 数组长度 <= 100
  - 所有颜色值在 0-255 范围内
  - 所有坐标在有效范围内
- **修饰符**: `external`
- **事件**: 触发 `BatchPixelsChanged` 事件
- **错误**: 
  - "Array lengths must match" - 数组长度不匹配
  - "Arrays cannot be empty" - 数组为空
  - "Batch size cannot exceed 100" - 批量大小超过限制
  - "Color value must be 0-255" - 颜色值超出范围
  - "X coordinate out of bounds" - x坐标超出范围
  - "Y coordinate out of bounds" - y坐标超出范围

### getUserContributionCount
```solidity
function getUserContributionCount(address user) external view returns (uint256)
```
- **描述**: 获取用户贡献的像素数量
- **参数**:
  - `user`: 用户地址
- **返回值**: 用户贡献的像素数量
- **修饰符**: `external view`

### getUserContributions
```solidity
function getUserContributions(address user) external view returns (uint256[] memory)
```
- **描述**: 获取用户贡献的像素索引列表
- **参数**:
  - `user`: 用户地址
- **返回值**: 像素索引数组
- **修饰符**: `external view`

### getUserContributionRatio
```solidity
function getUserContributionRatio(address user) external view returns (uint256)
```
- **描述**: 计算用户贡献比例（基点制）
- **参数**:
  - `user`: 用户地址
- **返回值**: 贡献比例（基点，10000 = 100%）
- **计算公式**: `(userContributionCount[user] * 10000) / TOTAL_PIXELS`
- **修饰符**: `external view`

### getCanvasProgress
```solidity
function getCanvasProgress() external view returns (uint256)
```
- **描述**: 获取画板进度（已绘制的像素数量）
- **返回值**: 已绘制的像素数量
- **修饰符**: `external view`

### getPixelColor
```solidity
function getPixelColor(uint256 x, uint256 y) external view returns (uint8)
```
- **描述**: 获取指定像素的颜色
- **参数**:
  - `x`: x坐标
  - `y`: y坐标
- **返回值**: 颜色值（0-255）
- **修饰符**: `external view`
- **错误**: 坐标转换函数会检查边界

### getPixelOwner
```solidity
function getPixelOwner(uint256 x, uint256 y) external view returns (address)
```
- **描述**: 获取指定像素的所有者
- **参数**:
  - `x`: x坐标
  - `y`: y坐标
- **返回值**: 像素所有者地址
- **修饰符**: `external view`
- **错误**: 坐标转换函数会检查边界

### getCanvasStats
```solidity
function getCanvasStats() external view returns (
    uint256 totalPixels_,
    uint256 totalDrawsCount_,
    uint256 uniqueContributorsCount_,
    uint256 completionPercentage_
)
```
- **描述**: 获取画板统计信息
- **返回值**:
  - `totalPixels_`: 总像素数
  - `totalDrawsCount_`: 总绘制次数
  - `uniqueContributorsCount_`: 独立贡献者数量
  - `completionPercentage_`: 完成百分比（基点制）
- **修饰符**: `external view`

## 事件

### PixelChanged
```solidity
event PixelChanged(
    address indexed artist, 
    uint256 indexed pixelIndex, 
    uint256 x, 
    uint256 y, 
    uint8 color
)
```
- **描述**: 单个像素变更事件
- **参数**:
  - `artist`: 绘制者地址（indexed）
  - `pixelIndex`: 像素索引（indexed）
  - `x`: x坐标
  - `y`: y坐标
  - `color`: 颜色值

### BatchPixelsChanged
```solidity
event BatchPixelsChanged(
    address indexed artist, 
    uint256[] pixelIndices, 
    uint256[] xCoords, 
    uint256[] yCoords, 
    uint8[] colors
)
```
- **描述**: 批量像素变更事件
- **参数**:
  - `artist`: 绘制者地址（indexed）
  - `pixelIndices`: 像素索引数组
  - `xCoords`: x坐标数组
  - `yCoords`: y坐标数组
  - `colors`: 颜色值数组

## 使用示例

### 基础使用
```solidity
// 部署合约
PublicPixelArt pixelArt = new PublicPixelArt();

// 绘制单个像素
pixelArt.drawPixel(10, 20, 255); // 在 (10,20) 绘制红色像素

// 批量绘制
uint256[] memory x = new uint256[](2);
uint256[] memory y = new uint256[](2);
uint8[] memory colors = new uint8[](2);
x[0] = 30; y[0] = 40; colors[0] = 128;
x[1] = 31; y[1] = 40; colors[1] = 200;
pixelArt.drawPixelsBatch(x, y, colors);

// 查询信息
uint256 myContributions = pixelArt.getUserContributionCount(msg.sender);
uint256 myRatio = pixelArt.getUserContributionRatio(msg.sender);
```

### 事件监听
```javascript
// 监听单个像素变更
pixelArt.on("PixelChanged", (artist, pixelIndex, x, y, color) => {
    console.log(`Pixel at (${x}, ${y}) changed to color ${color} by ${artist}`);
});

// 监听批量像素变更
pixelArt.on("BatchPixelsChanged", (artist, pixelIndices, xCoords, yCoords, colors) => {
    console.log(`Batch pixel change by ${artist}`);
    for (let i = 0; i < pixelIndices.length; i++) {
        console.log(`  Pixel at (${xCoords[i]}, ${yCoords[i]}) changed to color ${colors[i]}`);
    }
});
```

## 注意事项

1. **Gas 优化**: 建议使用批量绘制功能来降低 gas 成本
2. **坐标范围**: 所有坐标必须在 0-99 范围内
3. **颜色范围**: 颜色值必须在 0-255 范围内
4. **批量限制**: 单次批量操作最多处理 100 个像素
5. **贡献记录**: 只有首次绘制某个像素的用户才会被记录为贡献者
6. **比例计算**: 贡献比例基于总像素数计算，使用基点制（10000 = 100%）