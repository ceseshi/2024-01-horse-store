// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IHorseStore} from "../src/IHorseStore.sol";

contract HorseStoreInvariant is Test {
    IHorseStore horseStore;

    mapping(uint256 => address) public ownerOf;
    uint256[] public horses;

    constructor(address _horseStore) {
        horseStore = IHorseStore(_horseStore);
    }

    function getHorsesLength() external view returns (uint256) {
        return horses.length;
    }

    function mintHorse() external {
        if (address(msg.sender).code.length > 0) return;

        uint256 horseId = horseStore.totalSupply();
        horses.push(horseId);
        ownerOf[horseId] = msg.sender;

        vm.prank(msg.sender);
        horseStore.mintHorse();
    }

    function feedHorse() external {
        uint256 totalSupply = horseStore.totalSupply();
        if (totalSupply > 0) {
            horseStore.feedHorse(totalSupply - 1);
        }
    }

    function transferHorse(address to, uint256 tokenId) public {
        tokenId = bound(tokenId, 0, horses.length > 0 ? horses.length - 1 : 0);
        address from = ownerOf[tokenId];
        if (from != address(0) && to != address(0)) {
            vm.prank(from);
            horseStore.approve(address(this), tokenId);

            horseStore.transferFrom(from, to, tokenId);
            ownerOf[tokenId] = to;
        }
    }

    /*
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {
        horseStore.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        horseStore.safeTransferFrom(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        horseStore.transferFrom(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        horseStore.approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        horseStore.setApprovalForAll(operator, approved);
    }*/
}
