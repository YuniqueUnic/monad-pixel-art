// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PublicPixelArt} from "../src/PublicPixelArt.sol";

contract DeployPublicPixelArt is Script {
    function run() external returns (PublicPixelArt) {
        // 从环境变量中读取部署者私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 设置广播使用的私钥
        vm.startBroadcast(deployerPrivateKey);

        PublicPixelArt pixelArt = new PublicPixelArt();

        vm.stopBroadcast();

        // 输出部署信息
        address contractAddress = address(pixelArt);
        console.log("PublicPixelArt deployed to:", contractAddress);
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        return pixelArt;
    }
}
