//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public ActiveNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            ActiveNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            ActiveNetworkConfig = getMainnetEthConfig();
        } else {
            ActiveNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory Sepoliaconfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

        return Sepoliaconfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory Mainnetconfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});

        return Mainnetconfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (ActiveNetworkConfig.priceFeed != address(0)) {
            return ActiveNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockv3aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory Anvilconfig = NetworkConfig({priceFeed: address(mockv3aggregator)});

        return Anvilconfig;
    }
}
