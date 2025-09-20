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
        console.log("Canvas size:", pixelArt.CANVAS_WIDTH(), "x", pixelArt.CANVAS_HEIGHT());
        console.log("Total pixels:", pixelArt.TOTAL_PIXELS());
        
        // 示例：绘制一些像素
        address user = msg.sender;
        
        // 绘制单个像素
        pixelArt.drawPixel(10, 10, 255); // 红色
        pixelArt.drawPixel(11, 10, 0);   // 黑色
        pixelArt.drawPixel(12, 10, 128); // 灰色
        
        console.log("Drew 3 individual pixels");
        
        // 批量绘制像素
        uint256[] memory xCoords = new uint256[](5);
        uint256[] memory yCoords = new uint256[](5);
        uint8[] memory colors = new uint8[](5);
        
        for (uint256 i = 0; i < 5; i++) {
            xCoords[i] = 20 + i;
            yCoords[i] = 20;
            colors[i] = uint8(i * 50); // 不同的颜色
        }
        
        pixelArt.drawPixelsBatch(xCoords, yCoords, colors);
        console.log("Drew 5 pixels in batch");
        
        // 获取统计信息
        (uint256 totalPixels, uint256 totalDraws, uint256 uniqueContributors, uint256 completionPercentage) = 
            pixelArt.getCanvasStats();
        
        console.log("Canvas Stats:");
        console.log("  Total pixels:", totalPixels);
        console.log("  Total draws:", totalDraws);
        console.log("  Unique contributors:", uniqueContributors);
        console.log("  Completion percentage:", completionPercentage, "basis points");
        
        // 获取用户贡献信息
        uint256 userContributionCount = pixelArt.getUserContributionCount(user);
        uint256 userContributionRatio = pixelArt.getUserContributionRatio(user);
        
        console.log("User Contribution:");
        console.log("  Contribution count:", userContributionCount);
        console.log("  Contribution ratio:", userContributionRatio, "basis points");
        
        vm.stopBroadcast();
    }
}