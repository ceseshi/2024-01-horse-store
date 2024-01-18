// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base_Test, HorseStore, HorseStoreInvariant} from "./Base_Test.t.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract HorseStoreHuff is Base_Test {
    string public constant horseStoreLocation = "HorseStore";

    function setUp() public override {
        // Deploy HorseStore Huff bytecode
        horseStore = HorseStore(
            HuffDeployer.config().with_args(bytes.concat(abi.encode(NFT_NAME), abi.encode(NFT_SYMBOL))).deploy(
                horseStoreLocation
            )
        );

        horseStoreInvariant = new HorseStoreInvariant(address(horseStore));

        targetContract(address(horseStoreInvariant));
    }
}
