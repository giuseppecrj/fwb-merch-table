// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Script } from "forge-std/Script.sol";
import { MerchTable } from "../contracts/MerchTable.sol";

contract DeployMerchTable is Script {
    MerchTable internal merchTable;

    function run() public {
        vm.startBroadcast();

        address arbiter = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        merchTable = new MerchTable(arbiter);

        vm.stopBroadcast();
    }
}
