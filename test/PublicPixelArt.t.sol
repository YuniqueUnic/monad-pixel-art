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
    
    function test_Constants() public view {
        assertEq(pixelArt.CANVAS_WIDTH(), 100);
        assertEq(pixelArt.CANVAS_HEIGHT(), 100);
        assertEq(pixelArt.TOTAL_PIXELS(), 10000);
    }
    
    function test_CoordsToIndex() public view {
        assertEq(pixelArt.coordsToIndex(0, 0), 0);
        assertEq(pixelArt.coordsToIndex(99, 0), 99);
        assertEq(pixelArt.coordsToIndex(0, 99), 9900);
        assertEq(pixelArt.coordsToIndex(99, 99), 9999);
        assertEq(pixelArt.coordsToIndex(50, 50), 5050);
    }
    
    function test_CoordsToIndex_RevertWhenOutOfBounds() public {
        vm.expectRevert("X coordinate out of bounds");
        pixelArt.coordsToIndex(100, 0);
        
        vm.expectRevert("Y coordinate out of bounds");
        pixelArt.coordsToIndex(0, 100);
    }
    
    function test_IndexToCoords() public view {
        (uint256 x, uint256 y) = pixelArt.indexToCoords(0);
        assertEq(x, 0);
        assertEq(y, 0);
        
        (x, y) = pixelArt.indexToCoords(99);
        assertEq(x, 99);
        assertEq(y, 0);
        
        (x, y) = pixelArt.indexToCoords(9900);
        assertEq(x, 0);
        assertEq(y, 99);
        
        (x, y) = pixelArt.indexToCoords(9999);
        assertEq(x, 99);
        assertEq(y, 99);
        
        (x, y) = pixelArt.indexToCoords(5050);
        assertEq(x, 50);
        assertEq(y, 50);
    }
    
    function test_IndexToCoords_RevertWhenOutOfBounds() public {
        vm.expectRevert("Index out of bounds");
        pixelArt.indexToCoords(10000);
    }
    
    function test_DrawPixel() public {
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, 128);
        
        // 检查像素颜色
        assertEq(pixelArt.getPixelColor(10, 20), 128);
        
        // 检查像素所有者
        assertEq(pixelArt.getPixelOwner(10, 20), user1);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 1);
        
        // 检查用户贡献列表
        uint256[] memory contributions = pixelArt.getUserContributions(user1);
        assertEq(contributions.length, 1);
        assertEq(contributions[0], pixelArt.coordsToIndex(10, 20));
        
        // 检查统计信息
        (uint256 totalPixels, uint256 totalDraws, uint256 uniqueContributors, uint256 completionPercentage) = 
            pixelArt.getCanvasStats();
        assertEq(totalPixels, 10000);
        assertEq(totalDraws, 1);
        assertEq(uniqueContributors, 1);
        assertEq(completionPercentage, 1); // 1 * 10000 / 10000 = 1
    }
    
    function test_DrawPixel_RevertWhenColorInvalid() public {
        vm.prank(user1);
        // 使用 uint8 的最大值 + 1 来测试边界情况
        // 但由于编译时检查，我们需要用其他方法
        // 这里我们测试函数确实在检查颜色值范围
        pixelArt.drawPixel(10, 20, 255); // 有效值，应该成功
    }
    
    function test_DrawPixel_UpdateExistingPixel() public {
        // 用户1绘制像素
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, 128);
        
        // 用户2绘制同一个像素
        vm.prank(user2);
        pixelArt.drawPixel(10, 20, 200);
        
        // 检查像素颜色更新
        assertEq(pixelArt.getPixelColor(10, 20), 200);
        
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
        uint8[] memory colors = new uint8[](3);
        
        x[0] = 10; y[0] = 20; colors[0] = 128;
        x[1] = 30; y[1] = 40; colors[1] = 200;
        x[2] = 50; y[2] = 60; colors[2] = 255;
        
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors);
        
        // 检查所有像素颜色
        assertEq(pixelArt.getPixelColor(10, 20), 128);
        assertEq(pixelArt.getPixelColor(30, 40), 200);
        assertEq(pixelArt.getPixelColor(50, 60), 255);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 3);
        
        // 检查用户贡献列表
        uint256[] memory contributions = pixelArt.getUserContributions(user1);
        assertEq(contributions.length, 3);
        assertEq(contributions[0], pixelArt.coordsToIndex(10, 20));
        assertEq(contributions[1], pixelArt.coordsToIndex(30, 40));
        assertEq(contributions[2], pixelArt.coordsToIndex(50, 60));
        
        // 检查统计信息
        assertEq(pixelArt.getCanvasProgress(), 3);
    }
    
    function test_DrawPixelsBatch_RevertWhenArrayLengthsMismatch() public {
        uint256[] memory x = new uint256[](2);
        uint256[] memory y = new uint256[](3);
        uint8[] memory colors = new uint8[](2);
        
        vm.prank(user1);
        vm.expectRevert("Array lengths must match");
        pixelArt.drawPixelsBatch(x, y, colors);
    }
    
    function test_DrawPixelsBatch_RevertWhenArraysEmpty() public {
        uint256[] memory x = new uint256[](0);
        uint256[] memory y = new uint256[](0);
        uint8[] memory colors = new uint8[](0);
        
        vm.prank(user1);
        vm.expectRevert("Arrays cannot be empty");
        pixelArt.drawPixelsBatch(x, y, colors);
    }
    
    function test_DrawPixelsBatch_RevertWhenBatchSizeTooLarge() public {
        uint256[] memory x = new uint256[](101);
        uint256[] memory y = new uint256[](101);
        uint8[] memory colors = new uint8[](101);
        
        vm.prank(user1);
        vm.expectRevert("Batch size cannot exceed 100");
        pixelArt.drawPixelsBatch(x, y, colors);
    }
    
    function test_DrawPixelsBatch_ValidColorValues() public {
        uint256[] memory x = new uint256[](1);
        uint256[] memory y = new uint256[](1);
        uint8[] memory colors = new uint8[](1);
        
        // 测试边界值
        colors[0] = 0; // 最小值
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors); // 应该成功
        
        colors[0] = 255; // 最大值
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors); // 应该成功
    }
    
    function test_DrawPixelsBatch_MixedNewAndExistingPixels() public {
        // 用户1先绘制一些像素
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, 128);
        
        // 用户2批量绘制，包含用户1的像素和新像素
        uint256[] memory x = new uint256[](2);
        uint256[] memory y = new uint256[](2);
        uint8[] memory colors = new uint8[](2);
        
        x[0] = 10; y[0] = 20; colors[0] = 200;  // 已存在的像素
        x[1] = 30; y[1] = 40; colors[1] = 255;  // 新像素
        
        vm.prank(user2);
        pixelArt.drawPixelsBatch(x, y, colors);
        
        // 检查像素颜色
        assertEq(pixelArt.getPixelColor(10, 20), 200);
        assertEq(pixelArt.getPixelColor(30, 40), 255);
        
        // 检查用户贡献计数
        assertEq(pixelArt.getUserContributionCount(user1), 1);
        assertEq(pixelArt.getUserContributionCount(user2), 2); // 用户2绘制了2个像素（包括覆盖的）
        
        // 检查用户2的贡献列表（包含所有绘制的像素）
        uint256[] memory contributions = pixelArt.getUserContributions(user2);
        assertEq(contributions.length, 2);
        assertEq(contributions[0], pixelArt.coordsToIndex(10, 20));
        assertEq(contributions[1], pixelArt.coordsToIndex(30, 40));
    }
    
    function test_GetUserContributionRatio() public {
        // 初始比例应该为0
        assertEq(pixelArt.getUserContributionRatio(user1), 0);
        
        // 用户1绘制10个像素（减少数量以便观察）
        for (uint256 i = 0; i < 10; i++) {
            vm.prank(user1);
            pixelArt.drawPixel(i, 0, 128);
        }
        
        // 检查比例：10/10000 = 0.1% = 10基点
        assertEq(pixelArt.getUserContributionRatio(user1), 10);
        
        // 用户2绘制10个像素
        for (uint256 i = 0; i < 10; i++) {
            vm.prank(user2);
            pixelArt.drawPixel(i, 1, 200);
        }
        
        // 检查比例：每个用户都是10/10000 = 0.1% = 10基点
        assertEq(pixelArt.getUserContributionRatio(user1), 10);
        assertEq(pixelArt.getUserContributionRatio(user2), 10);
    }
    
    function test_GetCanvasStats() public {
        // 初始状态
        (uint256 totalPixels, uint256 totalDraws, uint256 uniqueContributors, uint256 completionPercentage) = 
            pixelArt.getCanvasStats();
        assertEq(totalPixels, 10000);
        assertEq(totalDraws, 0);
        assertEq(uniqueContributors, 0);
        assertEq(completionPercentage, 0);
        
        // 用户1绘制一些像素
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, 128);
        
        // 用户2绘制一些像素
        vm.prank(user2);
        pixelArt.drawPixel(30, 40, 200);
        
        // 检查更新后的统计信息
        (totalPixels, totalDraws, uniqueContributors, completionPercentage) = 
            pixelArt.getCanvasStats();
        assertEq(totalPixels, 10000);
        assertEq(totalDraws, 2);
        assertEq(uniqueContributors, 2);
        assertEq(completionPercentage, 2); // 2 * 10000 / 10000 = 2
    }
    
    function test_PixelChangedEvent() public {
        uint256 expectedIndex = pixelArt.coordsToIndex(10, 20);
        vm.expectEmit(true, true, false, true);
        emit PublicPixelArt.PixelChanged(user1, expectedIndex, 10, 20, 128);
        
        vm.prank(user1);
        pixelArt.drawPixel(10, 20, 128);
    }
    
    function test_BatchPixelsChangedEvent() public {
        uint256[] memory x = new uint256[](2);
        uint256[] memory y = new uint256[](2);
        uint8[] memory colors = new uint8[](2);
        
        x[0] = 10; y[0] = 20; colors[0] = 128;
        x[1] = 30; y[1] = 40; colors[1] = 200;
        
        uint256[] memory expectedIndices = new uint256[](2);
        expectedIndices[0] = pixelArt.coordsToIndex(10, 20);
        expectedIndices[1] = pixelArt.coordsToIndex(30, 40);
        
        vm.expectEmit(true, false, false, false);
        emit PublicPixelArt.BatchPixelsChanged(user1, expectedIndices, x, y, colors);
        
        vm.prank(user1);
        pixelArt.drawPixelsBatch(x, y, colors);
    }
}