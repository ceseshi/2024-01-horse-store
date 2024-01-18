// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HorseStore} from "../src/HorseStore.sol";
import {Test, console2} from "forge-std/Test.sol";

abstract contract Audit_Test is Test {
    HorseStore horseStore;
    address user = makeAddr("user");
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";

    function setUp() public virtual {
        horseStore = new HorseStore();
    }

    function testCanFeedHorseBeforeMint() public {
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        horseStore.feedHorse(0);

        vm.warp(block.timestamp + 3600);
        vm.prank(user);
        horseStore.mintHorse();
        bool isHappyHorse = horseStore.isHappyHorse(0);

        assertEq(isHappyHorse, true);
    }

    function testHorseIsUnhappyAfterFeeding() public {
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.prank(user);
        horseStore.mintHorse();

        vm.warp(block.timestamp + 3600);
        horseStore.feedHorse(0);

        vm.warp(block.timestamp + 3600);
        bool isHappyHorse = horseStore.isHappyHorse(0);

        assertEq(isHappyHorse, false);
    }

    function testAnyHorseIdCanBeChecked() public {
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        assertEq(horseStore.isHappyHorse(1337), false);
    }

    function testUnimplementedFunction() public {
        vm.prank(user);
        horseStore.mintHorse();
        uint256 token0index = horseStore.tokenByIndex(0);
        assertEq(token0index, horseStore.totalSupply());
    }

    function testMultipleMintFailsHuff() public {
        vm.startPrank(user);
        horseStore.mintHorse();
        vm.expectRevert();
        horseStore.mintHorse();
    }

    function testFeedOnInvalidTimestamp() public {
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        horseStore.mintHorse();

        vm.warp(block.timestamp - block.timestamp % 0x10);
        horseStore.feedHorse(0);

        vm.warp(block.timestamp - block.timestamp % 0x11);
        vm.expectRevert();
        horseStore.feedHorse(0);
    }

    /*function testLastOwner() public {
        vm.prank(user);
        horseStore.mintHorse();

        uint256 lastHorseId = horseStore.tokenByIndex(horseStore.totalSupply()-1);
        console2.log("lastHorseId", lastHorseId);
        assert(horseStore.ownerOf(lastHorseId) != address(0));
    }*/
}
