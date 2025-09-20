# PublicPixelArt 合约部署指南

## 前置条件

1. 安装 Foundry
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. 安装 dotenv (用于加载环境变量)
   ```bash
   npm install dotenv
   ```

## 部署步骤

### 1. 配置环境变量

复制环境变量模板文件：
```bash
cp .env.example .env
```

编辑 `.env` 文件，填入你的私钥和 RPC URL：
```env
# 部署账号私钥 (请勿将真实私钥提交到版本控制)
PRIVATE_KEY=0x-your-private-key-here

# RPC URL (例如: Monad测试网或主网)
RPC_URL=https://your-rpc-url-here

# 可选: 部署时使用的Gas Price
# GAS_PRICE=1000000000

# 可选: 部署时使用的Gas Limit
# GAS_LIMIT=2000000
```

### 2. 编译合约

```bash
forge build
```

### 3. 部署合约

#### 方式一：使用 forge script 部署

```bash
forge script script/DeployPublicPixelArt.s.sol --rpc-url $RPC_URL --broadcast --legacy
```

#### 方式二：使用 make 命令（推荐）

```bash
# 仅部署合约
make deploy

# 部署并自动验证合约（Monad测试网）
make deploy-and-verify

# 部署并自动验证合约（Monad主网）
make deploy-and-verify-mainnet
```

### 4. 验证合约

#### 方式一：部署后自动验证

使用 `make deploy-and-verify` 或 `make deploy-and-verify-mainnet` 命令可以在部署后自动验证合约。

#### 方式二：手动验证已部署的合约

如果你已经部署了合约但尚未验证，可以使用以下命令手动验证：

```bash
# 验证Monad测试网上的合约
make verify CONTRACT_ADDRESS=0x...

# 验证Monad主网上的合约
make verify-mainnet CONTRACT_ADDRESS=0x...
```

#### 方式三：直接使用 forge 命令验证

```bash
# 验证Monad测试网上的合约
forge verify-contract <contract_address> src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# 示例
forge verify-contract 0x195B9401D1BF64D4D4FFbEecD10aE8c41bEBA453 src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org
```

### 5. 验证部署

部署成功后，合约地址会显示在终端输出中。你可以使用以下命令验证合约是否成功部署：

```bash
# 查看部署信息
cast --rpc-url $RPC_URL code <deployed-contract-address>
```

验证成功后，你可以在 [Monad Explorer](https://testnet.monadexplorer.com/) (测试网) 或 [Monad Explorer](https://monadexplorer.com/) (主网) 上查看已验证的合约源代码。

## 部署到不同网络

### Monad 测试网

```bash
# 设置环境变量
export RPC_URL=https://testnet-rpc.monad.xyz

# 部署合约
forge script script/DeployPublicPixelArt.s.sol --rpc-url $RPC_URL --broadcast
```

### Monad 主网

```bash
# 设置环境变量
export RPC_URL=https://mainnet-rpc.monad.xyz

# 部署合约
forge script script/DeployPublicPixelArt.s.sol --rpc-url $RPC_URL --broadcast
```

## 合约 ABI

合约 ABI 已导出到 `out/PublicPixelArt.abi` 文件中，可以用于前端集成。

## 注意事项

1. **安全提醒**：请勿将包含真实私钥的 `.env` 文件提交到版本控制系统
2. **Gas 费用**：部署合约需要支付 Gas 费用，请确保部署账户有足够的资金
3. **网络选择**：请根据需要选择合适的网络进行部署
4. **合约验证**：部署完成后，建议在相应的区块链浏览器上验证合约源代码

## 常见问题

### 1. 部署失败

如果部署失败，请检查：
- 私钥是否正确
- RPC URL 是否有效
- 部署账户是否有足够的资金
- 网络连接是否正常

### 2. 环境变量未加载

如果环境变量未正确加载，可以尝试：
```bash
source .env
```

或者在命令前加上环境变量：
```bash
PRIVATE_KEY=0x-your-private-key RPC_URL=https://your-rpc-url forge script script/DeployPublicPixelArt.s.sol --rpc-url $RPC_URL --broadcast
```

### 3. 合约编译错误

如果编译出错，请检查：
- Solidity 版本是否正确
- 依赖是否正确安装
- 代码语法是否正确