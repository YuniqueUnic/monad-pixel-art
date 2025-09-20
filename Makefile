.PHONY: help build deploy verify clean test

# 默认目标
help:
	@echo "可用的命令:"
	@echo "  build     - 编译合约"
	@echo "  deploy    - 部署合约"
	@echo "  verify    - 验证已部署的合约"
	@echo "  clean     - 清理编译产物"
	@echo "  test      - 运行测试"

# 编译合约
build:
	forge build

# 部署合约
deploy: check-env check-balance
	@echo "开始部署合约..."
	forge script script/DeployPublicPixelArt.s.sol --rpc-url $(RPC_URL) --broadcast --legacy
	@echo "合约部署完成，如需验证请运行: make verify CONTRACT_ADDRESS=<合约地址>"

# 验证合约 (Monad测试网)
verify: check-env
	@if [ -z "$(CONTRACT_ADDRESS)" ]; then \
		echo "错误: 请提供合约地址，例如: make verify CONTRACT_ADDRESS=0x..."; \
		exit 1; \
	fi
	@echo "开始验证合约..."
	forge verify-contract $(CONTRACT_ADDRESS) src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# 验证合约 (Monad主网)
verify-mainnet: check-env
	@if [ -z "$(CONTRACT_ADDRESS)" ]; then \
		echo "错误: 请提供合约地址，例如: make verify-mainnet CONTRACT_ADDRESS=0x..."; \
		exit 1; \
	fi
	@echo "开始验证合约 (Monad主网)..."
	forge verify-contract $(CONTRACT_ADDRESS) src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# 部署并验证合约 (Monad测试网)
deploy-and-verify: check-env check-balance
	@echo "开始部署并验证合约..."
	@echo "部署合约..."
	@forge script script/DeployPublicPixelArt.s.sol --rpc-url $(RPC_URL) --broadcast --legacy --silent
	@echo "从广播日志中提取合约地址..."
	@CONTRACT_ADDRESS=$$(grep -o "PublicPixelArt deployed to: 0x[a-fA-F0-9]*" broadcast/latest/1-run-latest.json | cut -d' ' -f4); \
	if [ -z "$$CONTRACT_ADDRESS" ]; then \
		echo "错误: 无法从广播日志中提取合约地址"; \
		echo "请检查 broadcast/latest/1-run-latest.json 文件"; \
		exit 1; \
	fi; \
	echo "合约已部署到: $$CONTRACT_ADDRESS"; \
	echo "开始验证合约..."; \
	forge verify-contract $$CONTRACT_ADDRESS src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# 部署并验证合约 (Monad主网)
deploy-and-verify-mainnet: check-env
	@if [ -z "$(MAINNET_RPC_URL)" ]; then \
		echo "错误: 请在 .env 文件中设置 MAINNET_RPC_URL"; \
		exit 1; \
	fi
	@$(MAKE) check-balance RPC_URL=$(MAINNET_RPC_URL)
	@echo "开始部署并验证合约 (Monad主网)..."
	@echo "部署合约..."
	@forge script script/DeployPublicPixelArt.s.sol --rpc-url $(MAINNET_RPC_URL) --broadcast --legacy --silent
	@echo "从广播日志中提取合约地址..."
	@CONTRACT_ADDRESS=$$(grep -o "PublicPixelArt deployed to: 0x[a-fA-F0-9]*" broadcast/latest/1-run-latest.json | cut -d' ' -f4); \
	if [ -z "$$CONTRACT_ADDRESS" ]; then \
		echo "错误: 无法从广播日志中提取合约地址"; \
		echo "请检查 broadcast/latest/1-run-latest.json 文件"; \
		exit 1; \
	fi; \
	echo "合约已部署到: $$CONTRACT_ADDRESS"; \
	echo "开始验证合约..."; \
	forge verify-contract $$CONTRACT_ADDRESS src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# 清理编译产物
clean:
	forge clean
	rm -rf out/

# 运行测试
test:
	forge test

# 安装依赖
install:
	forge install foundry-rs/forge-std --no-commit
	forge install openzeppelin/openzeppelin-contracts --no-commit

# 检查环境变量
check-env:
	@if [ ! -f .env ]; then \
		echo "错误: .env 文件不存在，请复制 .env.example 并配置"; \
		exit 1; \
	fi
	@if [ -z "$$PRIVATE_KEY" ]; then \
		echo "错误: 请在 .env 文件中设置 PRIVATE_KEY"; \
		exit 1; \
	fi
	@if [ -z "$$RPC_URL" ]; then \
		echo "错误: 请在 .env 文件中设置 RPC_URL"; \
		exit 1; \
	fi

# 检查账户余额
check-balance:
	@echo "检查账户余额..."
	@DEPLOYER_ADDRESS=$$(cast wallet address --private-key $$PRIVATE_KEY); \
	echo "部署者地址: $$DEPLOYER_ADDRESS"; \
	BALANCE=$$(cast balance $$DEPLOYER_ADDRESS --rpc-url $(RPC_URL)); \
	echo "账户余额: $$BALANCE wei"; \
	if [ "$$BALANCE" = "0" ]; then \
		echo "错误: 账户余额不足，请向地址 $$DEPLOYER_ADDRESS 充值"; \
		exit 1; \
	fi; \
	echo "账户余额充足"

# 导出ABI
export-abi:
	@echo "导出合约 ABI..."
	mkdir -p out
	forge inspect src/PublicPixelArt.sol:PublicPixelArt abi > out/PublicPixelArt.abi

# 加载环境变量
include .env
export