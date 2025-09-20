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
deploy: check-env
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
deploy-and-verify: check-env
	@echo "开始部署并验证合约..."
	@echo "部署合约..."
	@CONTRACT_ADDRESS=$$(forge script script/DeployPublicPixelArt.s.sol --rpc-url $(RPC_URL) --broadcast --legacy --json | jq -r '.returns[0].value'); \
	echo "合约已部署到: $$CONTRACT_ADDRESS"; \
	echo "开始验证合约..."; \
	forge verify-contract $$CONTRACT_ADDRESS src/PublicPixelArt.sol:PublicPixelArt --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# 部署并验证合约 (Monad主网)
deploy-and-verify-mainnet: check-env
	@if [ -z "$(MAINNET_RPC_URL)" ]; then \
		echo "错误: 请在 .env 文件中设置 MAINNET_RPC_URL"; \
		exit 1; \
	fi
	@echo "开始部署并验证合约 (Monad主网)..."
	@echo "部署合约..."
	@CONTRACT_ADDRESS=$$(forge script script/DeployPublicPixelArt.s.sol --rpc-url $(MAINNET_RPC_URL) --broadcast --legacy --json | jq -r '.returns[0].value'); \
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

# 导出ABI
export-abi:
	@echo "导出合约 ABI..."
	mkdir -p out
	forge inspect src/PublicPixelArt.sol:PublicPixelArt abi > out/PublicPixelArt.abi

# 加载环境变量
include .env
export