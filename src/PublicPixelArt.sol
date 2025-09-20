// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title PublicPixelArt
 * @dev 公益链上像素画板合约
 * 基于 Monad 区块链的免费公益像素画板，让全球用户共同创作数字艺术品
 */
contract PublicPixelArt {
    // 像素信息结构体
    struct PixelInfo {
        uint256 x;
        uint256 y;
        uint8[] color;
        address owner;
    }

    // 核心数据结构
    mapping(uint256 => uint8[]) public pixels; // 像素颜色数据 (RGB数组)
    mapping(uint256 => address) public pixelOwners; // 像素归属记录
    mapping(address => uint256[]) public userContributions; // 用户贡献列表（像素索引）
    mapping(address => uint256) public userContributionCount; // 用户贡献计数
    PixelInfo[] public allPixels; // 存储所有像素信息的数组

    // 统计数据
    uint256 public totalDraws = 0; // 总绘制次数
    uint256 public uniqueContributors = 0; // 独立贡献者数量

    // 事件定义
    event PixelChanged(
        address indexed artist,
        uint256 indexed pixelIndex,
        uint256 x,
        uint256 y,
        uint8[] color
    );

    event BatchPixelsChanged(
        address indexed artist,
        uint256[] pixelIndices,
        uint256[] xCoords,
        uint256[] yCoords,
        uint8[][] colors
    );

    /**
     * @dev 生成像素的唯一键
     * @param x x坐标
     * @param y y坐标
     * @return 像素键
     */
    function getPixelKey(uint256 x, uint256 y) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(x, y)));
    }

    /**
     * @dev 绘制单个像素
     * @param x x坐标
     * @param y y坐标
     * @param color 颜色值 (RGB数组，通常为[R, G, B])
     */
    function drawPixel(uint256 x, uint256 y, uint8[] memory color) external {
        require(
            color.length == 3,
            "Color array must have exactly 3 elements (R, G, B)"
        );

        uint256 pixelKey = getPixelKey(x, y);
        address artist = msg.sender;

        // 更新像素数据
        pixels[pixelKey] = color;

        // 更新贡献记录（如果是新用户或新像素）
        if (pixelOwners[pixelKey] != artist) {
            pixelOwners[pixelKey] = artist;
            userContributions[artist].push(pixelKey);
            userContributionCount[artist]++;

            // 如果是用户第一次绘制，增加独立贡献者计数
            if (userContributionCount[artist] == 1) {
                uniqueContributors++;
            }
        }

        // 添加像素信息到数组
        allPixels.push(PixelInfo(x, y, color, artist));

        totalDraws++;

        emit PixelChanged(artist, pixelKey, x, y, color);
    }

    /**
     * @dev 批量绘制像素
     * @param x x坐标数组
     * @param y y坐标数组
     * @param colors 颜色值数组（RGB数组）
     */
    function drawPixelsBatch(
        uint256[] calldata x,
        uint256[] calldata y,
        uint8[][] calldata colors
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
            require(
                colors[i].length == 3,
                "Each color array must have exactly 3 elements (R, G, B)"
            );

            uint256 pixelKey = getPixelKey(x[i], y[i]);
            pixelIndices[i] = pixelKey;

            // 更新像素数据
            pixels[pixelKey] = colors[i];

            // 更新贡献记录（如果是新用户或新像素）
            if (pixelOwners[pixelKey] != artist) {
                pixelOwners[pixelKey] = artist;
                userContributions[artist].push(pixelKey);
                newContributions++;
            }

            // 添加像素信息到数组
            allPixels.push(PixelInfo(x[i], y[i], colors[i], artist));
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
        return userCount > 0 ? 10000 : 0; // 有贡献即为100%，否则为0
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
     * @return 颜色值 (RGB数组)
     */
    function getPixelColor(
        uint256 x,
        uint256 y
    ) external view returns (uint8[] memory) {
        uint256 pixelKey = getPixelKey(x, y);
        return pixels[pixelKey];
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
        uint256 pixelKey = getPixelKey(x, y);
        return pixelOwners[pixelKey];
    }

    /**
     * @dev 获取所有像素数据
     * @return x 所有像素的x坐标数组
     * @return y 所有像素的y坐标数组
     * @return colors 所有像素的颜色数组
     */
    function getPixels()
        external
        view
        returns (
            uint256[] memory x,
            uint256[] memory y,
            uint8[][] memory colors
        )
    {
        uint256 length = allPixels.length;
        x = new uint256[](length);
        y = new uint256[](length);
        colors = new uint8[][](length);

        for (uint256 i = 0; i < length; i++) {
            x[i] = allPixels[i].x;
            y[i] = allPixels[i].y;
            colors[i] = allPixels[i].color;
        }
    }

    /**
     * @dev 获取画板统计信息
     * @return totalPixels_ 总像素数（现在为0，表示无限制）
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
        totalPixels_ = 0; // 不再限制总像素数
        totalDrawsCount_ = totalDraws;
        uniqueContributorsCount_ = uniqueContributors;
        completionPercentage_ = totalDraws > 0 ? 10000 : 0; // 有绘制即为100%
    }
}
