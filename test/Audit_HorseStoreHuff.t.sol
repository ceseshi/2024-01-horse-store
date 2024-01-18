// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Audit_Test, HorseStore} from "./Audit_Test.t.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract Audit_HorseStoreHuff is Audit_Test {
    string public constant horseStoreLocation = "HorseStore";

    function setUp() public override {
        // Deploy HorseStore Huff bytecode
        horseStore = HorseStore(
            //HorseStore horseStoreHuff = HorseStore(
            HuffDeployer.config().with_args(bytes.concat(abi.encode(NFT_NAME), abi.encode(NFT_SYMBOL))).deploy(
                horseStoreLocation
            )
        );
    }
}
