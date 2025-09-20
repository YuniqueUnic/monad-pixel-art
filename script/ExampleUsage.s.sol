// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PublicPixelArt.sol";

contract ExampleUsage is Script {
    function run() external {
        vm.startBroadcast();

        // 部署合约
        PublicPixelArt pixelArt = new PublicPixelArt();

        console.log("PublicPixelArt deployed at:", address(pixelArt));
        console.log("Canvas size: Unlimited (no fixed dimensions)");
        console.log("Total pixels: Unlimited (dynamic based on usage)");

        // 示例：绘制一些像素
        address user = msg.sender;

        // 绘制单个像素
        uint8[] memory red = new uint8[](3);
        red[0] = 255;
        red[1] = 0;
        red[2] = 0; // RGB红色
        pixelArt.drawPixel(10, 10, red);

        uint8[] memory black = new uint8[](3);
        black[0] = 0;
        black[1] = 0;
        black[2] = 0; // RGB黑色
        pixelArt.drawPixel(11, 10, black);

        uint8[] memory gray = new uint8[](3);
        gray[0] = 128;
        gray[1] = 128;
        gray[2] = 128; // RGB灰色
        pixelArt.drawPixel(12, 10, gray);

        console.log("Drew 3 individual pixels");

        // 批量绘制像素
        uint256[] memory xCoords = new uint256[](5);
        uint256[] memory yCoords = new uint256[](5);
        uint8[][] memory colors = new uint8[][](5);

        for (uint256 i = 0; i < 5; i++) {
            xCoords[i] = 20 + i;
            yCoords[i] = 20;
            colors[i] = new uint8[](3);
            colors[i][0] = uint8(i * 50); // R
            colors[i][1] = uint8(255 - i * 50); // G
            colors[i][2] = uint8(i * 25); // B
        }

        pixelArt.drawPixelsBatch(xCoords, yCoords, colors);
        console.log("Drew 5 pixels in batch");

        // 获取统计信息
        (
            uint256 totalPixels,
            uint256 totalDraws,
            uint256 uniqueContributors,
            uint256 completionPercentage
        ) = pixelArt.getCanvasStats();

        console.log("Canvas Stats:");
        console.log("  Total pixels:", totalPixels);
        console.log("  Total draws:", totalDraws);
        console.log("  Unique contributors:", uniqueContributors);
        console.log(
            "  Completion percentage:",
            completionPercentage,
            "basis points"
        );

        // 获取用户贡献信息
        uint256 userContributionCount = pixelArt.getUserContributionCount(user);
        uint256 userContributionRatio = pixelArt.getUserContributionRatio(user);

        console.log("User Contribution:");
        console.log("  Contribution count:", userContributionCount);
        console.log(
            "  Contribution ratio:",
            userContributionRatio,
            "basis points"
        );

        vm.stopBroadcast();
    }
}
