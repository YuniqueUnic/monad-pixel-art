.PHONY: help build deploy clean test

# 默认目标
help:
	@echo "可用的命令:"
	@echo "  build     - 编译合约"
	@echo "  deploy    - 部署合约"
	@echo "  clean     - 清理编译产物"
	@echo "  test      - 运行测试"

# 编译合约
build:
	forge build

# 部署合约
deploy:
	@echo "开始部署合约..."
	@echo "请确保已在 .env 文件中配置了 PRIVATE_KEY 和 RPC_URL"
	forge script script/DeployPublicPixelArt.s.sol --rpc-url $(RPC_URL) --broadcast

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