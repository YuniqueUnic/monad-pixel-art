// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title PublicPixelArt
 * @dev 公益链上像素画板合约
 * 基于 Monad 区块链的免费公益像素画板，让全球用户共同创作数字艺术品
 */
contract PublicPixelArt {
    // 画板尺寸：100x100 = 10,000个像素
    uint256 public constant CANVAS_WIDTH = 100;
    uint256 public constant CANVAS_HEIGHT = 100;
    uint256 public constant TOTAL_PIXELS = CANVAS_WIDTH * CANVAS_HEIGHT;

    // 核心数据结构
    mapping(uint256 => uint8) public pixels; // 像素颜色数据 (0-255)
    mapping(uint256 => address) public pixelOwners; // 像素归属记录
    mapping(address => uint256[]) public userContributions; // 用户贡献列表（像素索引）
    mapping(address => uint256) public userContributionCount; // 用户贡献计数

    // 统计数据
    uint256 public totalDraws = 0; // 总绘制次数
    uint256 public uniqueContributors = 0; // 独立贡献者数量

    // 事件定义
    event PixelChanged(
        address indexed artist,
        uint256 indexed pixelIndex,
        uint256 x,
        uint256 y,
        uint8 color
    );

    event BatchPixelsChanged(
        address indexed artist,
        uint256[] pixelIndices,
        uint256[] xCoords,
        uint256[] yCoords,
        uint8[] colors
    );

    /**
     * @dev 将二维坐标转换为一维索引
     * @param x x坐标
     * @param y y坐标
     * @return 一维索引
     */
    function coordsToIndex(uint256 x, uint256 y) public pure returns (uint256) {
        require(x < CANVAS_WIDTH, "X coordinate out of bounds");
        require(y < CANVAS_HEIGHT, "Y coordinate out of bounds");
        return y * CANVAS_WIDTH + x;
    }

    /**
     * @dev 将一维索引转换为二维坐标
     * @param index 一维索引
     * @return x x坐标
     * @return y y坐标
     */
    function indexToCoords(
        uint256 index
    ) public pure returns (uint256 x, uint256 y) {
        require(index < TOTAL_PIXELS, "Index out of bounds");
        x = index % CANVAS_WIDTH;
        y = index / CANVAS_WIDTH;
    }

    /**
     * @dev 绘制单个像素
     * @param x x坐标
     * @param y y坐标
     * @param color 颜色值 (0-255)
     */
    function drawPixel(uint256 x, uint256 y, uint8 color) external {
        // 内联坐标转换以节省 Gas
        require(x < CANVAS_WIDTH, "X coordinate out of bounds");
        require(y < CANVAS_HEIGHT, "Y coordinate out of bounds");
        require(color <= 255, "Color value must be 0-255");

        uint256 pixelIndex = y * CANVAS_WIDTH + x;
        address artist = msg.sender;

        // 更新像素数据
        pixels[pixelIndex] = color;

        // 更新贡献记录（如果是新用户或新像素）
        if (pixelOwners[pixelIndex] != artist) {
            pixelOwners[pixelIndex] = artist;
            userContributions[artist].push(pixelIndex);
            userContributionCount[artist]++;

            // 如果是用户第一次绘制，增加独立贡献者计数
            if (userContributionCount[artist] == 1) {
                uniqueContributors++;
            }
        }

        totalDraws++;

        emit PixelChanged(artist, pixelIndex, x, y, color);
    }

    /**
     * @dev 批量绘制像素
     * @param x x坐标数组
     * @param y y坐标数组
     * @param colors 颜色值数组
     */
    function drawPixelsBatch(
        uint256[] calldata x,
        uint256[] calldata y,
        uint8[] calldata colors
    ) external {
        uint256 length = x.length;
        require(
            length == y.length && length == colors.length,
            "Array lengths must match"
        );
        require(length > 0, "Arrays cannot be empty");
        require(length <= 100, "Batch size cannot exceed 100");

        address artist = msg.sender;
        uint256[] memory pixelIndices = new uint256[](length);
        uint256 newContributions = 0;

        // 处理每个像素
        for (uint256 i = 0; i < length; i++) {
            require(colors[i] <= 255, "Color value must be 0-255");
            require(x[i] < CANVAS_WIDTH, "X coordinate out of bounds");
            require(y[i] < CANVAS_HEIGHT, "Y coordinate out of bounds");

            // 内联坐标转换以节省 Gas
            uint256 pixelIndex = y[i] * CANVAS_WIDTH + x[i];
            pixelIndices[i] = pixelIndex;

            // 更新像素数据
            pixels[pixelIndex] = colors[i];

            // 更新贡献记录（如果是新用户或新像素）
            if (pixelOwners[pixelIndex] != artist) {
                pixelOwners[pixelIndex] = artist;
                userContributions[artist].push(pixelIndex);
                newContributions++;
            }
        }

        // 更新用户贡献计数和统计
        if (newContributions > 0) {
            userContributionCount[artist] += newContributions;

            // 如果是用户第一次绘制，增加独立贡献者计数
            if (userContributionCount[artist] == newContributions) {
                uniqueContributors++;
            }
        }

        totalDraws += length;

        emit BatchPixelsChanged(artist, pixelIndices, x, y, colors);
    }

    /**
     * @dev 获取用户贡献数量
     * @param user 用户地址
     * @return 贡献的像素数量
     */
    function getUserContributionCount(
        address user
    ) external view returns (uint256) {
        return userContributionCount[user];
    }

    /**
     * @dev 获取用户贡献的像素索引列表
     * @param user 用户地址
     * @return 像素索引数组
     */
    function getUserContributions(
        address user
    ) external view returns (uint256[] memory) {
        return userContributions[user];
    }

    /**
     * @dev 计算用户贡献比例（基点制，10000 = 100%）
     * @param user 用户地址
     * @return 贡献比例（基点）
     */
    function getUserContributionRatio(
        address user
    ) external view returns (uint256) {
        if (totalDraws == 0) {
            return 0;
        }

        uint256 userCount = userContributionCount[user];
        return (userCount * 10000) / TOTAL_PIXELS;
    }

    /**
     * @dev 获取画板进度（已绘制的像素数量）
     * @return 已绘制的像素数量
     */
    function getCanvasProgress() external view returns (uint256) {
        return totalDraws;
    }

    /**
     * @dev 获取指定像素的颜色
     * @param x x坐标
     * @param y y坐标
     * @return 颜色值
     */
    function getPixelColor(uint256 x, uint256 y) external view returns (uint8) {
        uint256 pixelIndex = coordsToIndex(x, y);
        return pixels[pixelIndex];
    }

    /**
     * @dev 获取指定像素的所有者
     * @param x x坐标
     * @param y y坐标
     * @return 像素所有者地址
     */
    function getPixelOwner(
        uint256 x,
        uint256 y
    ) external view returns (address) {
        uint256 pixelIndex = coordsToIndex(x, y);
        return pixelOwners[pixelIndex];
    }

    /**
     * @dev 获取画板统计信息
     * @return totalPixels_ 总像素数
     * @return totalDrawsCount_ 总绘制次数
     * @return uniqueContributorsCount_ 独立贡献者数量
     * @return completionPercentage_ 完成百分比（基点制）
     */
    function getCanvasStats()
        external
        view
        returns (
            uint256 totalPixels_,
            uint256 totalDrawsCount_,
            uint256 uniqueContributorsCount_,
            uint256 completionPercentage_
        )
    {
        totalPixels_ = TOTAL_PIXELS;
        totalDrawsCount_ = totalDraws;
        uniqueContributorsCount_ = uniqueContributors;
        completionPercentage_ = (totalDraws * 10000) / TOTAL_PIXELS;
    }
}
