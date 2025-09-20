// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PublicPixelArt.sol";

contract DebugTest is Test {
    PublicPixelArt public pixelArt;
    address public user1 = address(0x1);
    
    function setUp() public {
        pixelArt = new PublicPixelArt();
    }
    
    function test_DebugContributionRatio() public {
        // 用户1绘制1个像素
        vm.prank(user1);
        pixelArt.drawPixel(0, 0, 128);
        
        // 检查用户贡献计数
        uint256 userCount = pixelArt.getUserContributionCount(user1);
        emit log_named_uint("User contribution count", userCount);
        
        // 检查总像素数
        uint256 totalPixels = pixelArt.TOTAL_PIXELS();
        emit log_named_uint("Total pixels", totalPixels);
        
        // 检查实际比例
        uint256 actualRatio = pixelArt.getUserContributionRatio(user1);
        emit log_named_uint("Actual ratio", actualRatio);
        
        // 手动计算期望比例
        uint256 expectedRatio = (userCount * 10000) / totalPixels;
        emit log_named_uint("Expected ratio", expectedRatio);
        
        // 断言
        assertEq(actualRatio, expectedRatio);
    }
}