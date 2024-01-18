// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HorseStore} from "../src/HorseStore.sol";
import {HorseStoreInvariant} from "./HorseStoreInvariant.t.sol";
import {Test, console2} from "forge-std/Test.sol";

abstract contract Base_Test is Test {
    HorseStore horseStore;
    address user = makeAddr("user");
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";

    HorseStoreInvariant horseStoreInvariant;

    function setUp() public virtual {
        horseStore = new HorseStore();

        horseStoreInvariant = new HorseStoreInvariant(address(horseStore));

        targetContract(address(horseStoreInvariant));
    }

    function testName() public {
        string memory name = horseStore.name();
        assertEq(name, NFT_NAME);
    }

    function testMintingHorseAssignsOwner(address randomOwner) public {
        vm.assume(randomOwner != address(0));
        vm.assume(!_isContract(randomOwner));

        uint256 horseId = horseStore.totalSupply();
        vm.prank(randomOwner);
        horseStore.mintHorse();
        assertEq(horseStore.ownerOf(horseId), randomOwner);
    }

    function testFeedingHorseUpdatesTimestamps() public {
        uint256 horseId = horseStore.totalSupply();
        vm.warp(10);
        vm.roll(10);
        vm.prank(user);
        horseStore.mintHorse();

        uint256 lastFedTimeStamp = block.timestamp;
        horseStore.feedHorse(horseId);

        assertEq(horseStore.horseIdToFedTimeStamp(horseId), lastFedTimeStamp);
    }

    function testFeedingMakesHappyHorse() public {
        uint256 horseId = horseStore.totalSupply();
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.roll(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.prank(user);
        horseStore.mintHorse();
        horseStore.feedHorse(horseId);
        assertEq(horseStore.isHappyHorse(horseId), true);
    }

    function testNotFeedingMakesUnhappyHorse() public {
        uint256 horseId = horseStore.totalSupply();
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.roll(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.prank(user);
        horseStore.mintHorse();
        assertEq(horseStore.isHappyHorse(horseId), false);
    }

    function testTransferHorse() public {
        uint256 horseId = horseStore.totalSupply();
        address user2 = makeAddr("user2");

        vm.prank(user);
        horseStore.mintHorse();

        vm.prank(user);
        horseStore.transferFrom(user, user2, horseId);

        vm.prank(user);
        horseStore.mintHorse();

        assertEq(horseStore.balanceOf(user), 1);
        assertEq(horseStore.balanceOf(user2), 1);
        assertEq(horseStore.ownerOf(horseId), user2);
    }

    function invariant_testTotalSupply() public {
        uint256 totalSupply = horseStore.totalSupply();
        assert(totalSupply == 0 || horseStore.ownerOf(totalSupply - 1) == horseStoreInvariant.ownerOf(totalSupply - 1));
        assertEq(totalSupply, horseStoreInvariant.getHorsesLength());
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    // Borrowed from an Old Openzeppelin codebase
    function _isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
