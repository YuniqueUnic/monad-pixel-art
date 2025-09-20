// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PublicPixelArt.sol";

contract DeployPublicPixelArt is Script {
    function run() external returns (PublicPixelArt) {
        vm.startBroadcast();
        
        PublicPixelArt pixelArt = new PublicPixelArt();
        
        vm.stopBroadcast();
        
        return pixelArt;
    }
}