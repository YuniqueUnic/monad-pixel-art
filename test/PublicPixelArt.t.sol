// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PublicPixelArt.sol";

contract PublicPixelArtTest is Test {
    PublicPixelArt public pixelArt;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    
    function setUp() public {
        pixelArt = new PublicPixelArt();
    }
    
    function test_GetPixelKey() public view {
        uint256 key1 = pixelArt.getPixelKey(10, 20);
        uint256 key2 = pixelArt.getPixelKey(10, 20);
        uint256 key3 = pixelArt.getPixelKey(30, 40);
        
        // 相同坐标应该生成相同的键
        assertEq(key1, key2);
        
        // 不同坐标应该生成不同的键
        assert(key1 != key3);
        
        // 键应该是确定的（相同的输入总是产生相同的输出）
        assertEq(pixelArt.getPixelKey(0, 0), pixelArt.getPixelKey(0, 0));
    }
    
    
    function test_DrawPixel() public {
        uint8[] memory color = new uint8[](3);
        color[0] = 255; // R
        color[1] = 0;   // G
        color[2] = 0;   // B
        
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, color);
        
        // 检查像素颜色
        uint8[] memory retrievedColor = pixelArt.getPixelColor(10, 20);
        assertEq(retrievedColor.length, 3);
        assertEq(retrievedColor[0], 255);
        assertEq(retrievedColor[1], 0);
        assertEq(retrievedColor[2], 0);
        
        // 检查像素所有者
        assertEq(pixelArt.getPixelOwner(10, 20), user1);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 1);
        
        // 检查用户贡献列表
        uint256[] memory contributions = pixelArt.getUserContributions(user1);
        assertEq(contributions.length, 1);
        assertEq(contributions[0], pixelArt.getPixelKey(10, 20));
        
        // 检查统计信息
        (uint256 totalPixels, uint256 totalDraws, uint256 uniqueContributors, uint256 completionPercentage) =
            pixelArt.getCanvasStats();
        assertEq(totalPixels, 0); // 不再限制总像素数
        assertEq(totalDraws, 1);
        assertEq(uniqueContributors, 1);
        assertEq(completionPercentage, 10000); // 有绘制即为100%
    }
    
    function test_DrawPixel_RevertWhenColorInvalid() public {
        uint8[] memory invalidColor = new uint8[](2); // 错误的长度
        invalidColor[0] = 255;
        invalidColor[1] = 0;
        
        vm.prank(user1);
        vm.expectRevert("Color array must have exactly 3 elements (R, G, B)");
        pixelArt.drawPixel(10, 20, invalidColor);
    }
    
    function test_DrawPixel_UpdateExistingPixel() public {
        // 用户1绘制像素
        uint8[] memory color1 = new uint8[](3);
        color1[0] = 255; color1[1] = 0; color1[2] = 0; // 红色
        
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, color1);
        
        // 用户2绘制同一个像素
        uint8[] memory color2 = new uint8[](3);
        color2[0] = 0; color2[1] = 255; color2[2] = 0; // 绿色
        
        vm.prank(user2);
        pixelArt.drawPixel(10, 20, color2);
        
        // 检查像素颜色更新
        uint8[] memory retrievedColor = pixelArt.getPixelColor(10, 20);
        assertEq(retrievedColor[0], 0);
        assertEq(retrievedColor[1], 255);
        assertEq(retrievedColor[2], 0);
        
        // 检查像素所有者更新
        assertEq(pixelArt.getPixelOwner(10, 20), user2);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 1);
        assertEq(pixelArt.getUserContributionCount(user2), 1);
        
        // 检查总绘制次数
        assertEq(pixelArt.getCanvasProgress(), 2);
    }
    
    function test_DrawPixelsBatch() public {
        uint256[] memory x = new uint256[](3);
        uint256[] memory y = new uint256[](3);
        uint8[][] memory colors = new uint8[][](3);
        
        // 红色
        colors[0] = new uint8[](3);
        colors[0][0] = 255; colors[0][1] = 0; colors[0][2] = 0;
        x[0] = 10; y[0] = 20;
        
        // 绿色
        colors[1] = new uint8[](3);
        colors[1][0] = 0; colors[1][1] = 255; colors[1][2] = 0;
        x[1] = 30; y[1] = 40;
        
        // 蓝色
        colors[2] = new uint8[](3);
        colors[2][0] = 0; colors[2][1] = 0; colors[2][2] = 255;
        x[2] = 50; y[2] = 60;
        
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors);
        
        // 检查所有像素颜色
        uint8[] memory color1 = pixelArt.getPixelColor(10, 20);
        assertEq(color1[0], 255); assertEq(color1[1], 0); assertEq(color1[2], 0);
        
        uint8[] memory color2 = pixelArt.getPixelColor(30, 40);
        assertEq(color2[0], 0); assertEq(color2[1], 255); assertEq(color2[2], 0);
        
        uint8[] memory color3 = pixelArt.getPixelColor(50, 60);
        assertEq(color3[0], 0); assertEq(color3[1], 0); assertEq(color3[2], 255);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 3);
        
        // 检查用户贡献列表
        uint256[] memory contributions = pixelArt.getUserContributions(user1);
        assertEq(contributions.length, 3);
        assertEq(contributions[0], pixelArt.getPixelKey(10, 20));
        assertEq(contributions[1], pixelArt.getPixelKey(30, 40));
        assertEq(contributions[2], pixelArt.getPixelKey(50, 60));
        
        // 检查统计信息
        assertEq(pixelArt.getCanvasProgress(), 3);
    }
    
    function test_DrawPixelsBatch_RevertWhenArrayLengthsMismatch() public {
        uint256[] memory x = new uint256[](2);
        uint256[] memory y = new uint256[](3);
        uint8[][] memory colors = new uint8[][](2);
        
        vm.prank(user1);
        vm.expectRevert("Array lengths must match");
        pixelArt.drawPixelsBatch(x, y, colors);
    }
    
    function test_DrawPixelsBatch_RevertWhenArraysEmpty() public {
        uint256[] memory x = new uint256[](0);
        uint256[] memory y = new uint256[](0);
        uint8[][] memory colors = new uint8[][](0);
        
        vm.prank(user1);
        vm.expectRevert("Arrays cannot be empty");
        pixelArt.drawPixelsBatch(x, y, colors);
    }
    
    function test_DrawPixelsBatch_RevertWhenBatchSizeTooLarge() public {
        uint256[] memory x = new uint256[](101);
        uint256[] memory y = new uint256[](101);
        uint8[][] memory colors = new uint8[][](101);
        
        vm.prank(user1);
        vm.expectRevert("Batch size cannot exceed 100");
        pixelArt.drawPixelsBatch(x, y, colors);
    }
    
    function test_DrawPixelsBatch_ValidColorValues() public {
        uint256[] memory x = new uint256[](1);
        uint256[] memory y = new uint256[](1);
        uint8[][] memory colors = new uint8[][](1);
        
        // 测试有效的RGB颜色
        colors[0] = new uint8[](3);
        colors[0][0] = 255; colors[0][1] = 0; colors[0][2] = 0; // 红色
        
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors); // 应该成功
    }
    
    function test_DrawPixelsBatch_MixedNewAndExistingPixels() public {
        // 用户1先绘制一些像素
        uint8[] memory color1 = new uint8[](3);
        color1[0] = 128; color1[1] = 128; color1[2] = 128; // 灰色
        
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, color1);
        
        // 用户2批量绘制，包含用户1的像素和新像素
        uint256[] memory x = new uint256[](2);
        uint256[] memory y = new uint256[](2);
        uint8[][] memory colors = new uint8[][](2);
        
        // 红色 - 覆盖现有像素
        colors[0] = new uint8[](3);
        colors[0][0] = 255; colors[0][1] = 0; colors[0][2] = 0;
        x[0] = 10; y[0] = 20;
        
        // 蓝色 - 新像素
        colors[1] = new uint8[](3);
        colors[1][0] = 0; colors[1][1] = 0; colors[1][2] = 255;
        x[1] = 30; y[1] = 40;
        
        vm.prank(user2);
        pixelArt.drawPixelsBatch(x, y, colors);
        
        // 检查像素颜色
        uint8[] memory retrievedColor1 = pixelArt.getPixelColor(10, 20);
        assertEq(retrievedColor1[0], 255); assertEq(retrievedColor1[1], 0); assertEq(retrievedColor1[2], 0);
        
        uint8[] memory retrievedColor2 = pixelArt.getPixelColor(30, 40);
        assertEq(retrievedColor2[0], 0); assertEq(retrievedColor2[1], 0); assertEq(retrievedColor2[2], 255);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 1);
        assertEq(pixelArt.getUserContributionCount(user2), 2); // 用户2绘制了2个像素（包括覆盖的）
        
        // 检查用户2的贡献列表（包含所有绘制的像素）
        uint256[] memory contributions = pixelArt.getUserContributions(user2);
        assertEq(contributions.length, 2);
        assertEq(contributions[0], pixelArt.getPixelKey(10, 20));
        assertEq(contributions[1], pixelArt.getPixelKey(30, 40));
    }
    
    function test_GetUserContributionRatio() public {
        // 初始比例应该为0
        assertEq(pixelArt.getUserContributionRatio(user1), 0);
        
        // 用户1绘制3个像素
        uint8[] memory color = new uint8[](3);
        color[0] = 255; color[1] = 0; color[2] = 0; // 红色
        
        for (uint256 i = 0; i < 3; i++) {
            vm.prank(user1);
            pixelArt.drawPixel(i, 0, color);
        }
        
        // 检查比例：现在简化了计算逻辑
        assertEq(pixelArt.getUserContributionRatio(user1), 10000); // 有贡献即为100%
        
        // 用户2绘制2个像素
        uint8[] memory color2 = new uint8[](3);
        color2[0] = 0; color2[1] = 255; color2[2] = 0; // 绿色
        
        for (uint256 i = 0; i < 2; i++) {
            vm.prank(user2);
            pixelArt.drawPixel(i, 1, color2);
        }
        
        // 检查比例：每个用户都有贡献，都是100%
        assertEq(pixelArt.getUserContributionRatio(user1), 10000);
        assertEq(pixelArt.getUserContributionRatio(user2), 10000);
    }
    
    function test_GetCanvasStats() public {
        // 初始状态
        (uint256 totalPixels, uint256 totalDraws, uint256 uniqueContributors, uint256 completionPercentage) =
            pixelArt.getCanvasStats();
        assertEq(totalPixels, 0); // 不再限制总像素数
        assertEq(totalDraws, 0);
        assertEq(uniqueContributors, 0);
        assertEq(completionPercentage, 0);
        
        // 用户1绘制一些像素
        uint8[] memory color1 = new uint8[](3);
        color1[0] = 255; color1[1] = 0; color1[2] = 0; // 红色
        
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, color1);
        
        // 用户2绘制一些像素
        uint8[] memory color2 = new uint8[](3);
        color2[0] = 0; color2[1] = 255; color2[2] = 0; // 绿色
        
        vm.prank(user2);
        pixelArt.drawPixel(30, 40, color2);
        
        // 检查更新后的统计信息
        (totalPixels, totalDraws, uniqueContributors, completionPercentage) =
            pixelArt.getCanvasStats();
        assertEq(totalPixels, 0); // 不再限制总像素数
        assertEq(totalDraws, 2);
        assertEq(uniqueContributors, 2);
        assertEq(completionPercentage, 10000); // 有绘制即为100%
    }
    
    function test_PixelChangedEvent() public {
        uint256 expectedIndex = pixelArt.coordsToIndex(10, 20);
        uint8[] memory color = new uint8[](3);
        color[0] = 255; color[1] = 0; color[2] = 0; // 红色
        
        vm.expectEmit(true, true, false, true);
        emit PublicPixelArt.PixelChanged(user1, expectedKey, 10, 20, color);
        
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, color);
    }
    
    function test_BatchPixelsChangedEvent() public {
        uint256[] memory x = new uint256[](2);
        uint256[] memory y = new uint256[](2);
        uint8[][] memory colors = new uint8[][](2);
        
        // 红色
        colors[0] = new uint8[](3);
        colors[0][0] = 255; colors[0][1] = 0; colors[0][2] = 0;
        x[0] = 10; y[0] = 20;
        
        // 绿色
        colors[1] = new uint8[](3);
        colors[1][0] = 0; colors[1][1] = 255; colors[1][2] = 0;
        x[1] = 30; y[1] = 40;
        
        uint256[] memory expectedKeys = new uint256[](2);
        expectedKeys[0] = pixelArt.getPixelKey(10, 20);
        expectedKeys[1] = pixelArt.getPixelKey(30, 40);
        
        vm.expectEmit(true, false, false, false);
        emit PublicPixelArt.BatchPixelsChanged(user1, expectedKeys, x, y, colors);
        
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors);
    }
}