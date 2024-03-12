//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperconfig = new HelperConfig();
        address EthUsdPriceFeed = helperconfig.ActiveNetworkConfig();

        vm.startBroadcast();
        FundMe fundeme = new FundMe(EthUsdPriceFeed);
        vm.stopBroadcast();
        return fundeme;
    }
}
