//SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./ItemManager.sol";

contract Item {
    uint public priceInWei;
    uint public pricePaid;
    uint public index;

    ItemManager parentContract;

    constructor(ItemManager _parenContract, uint _priceInWei, uint _index) public {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parenContract;
    }

    receive() external payable {
        require(pricePaid == 0, "Item is paid already");
        require(pricePaid == msg.value, "Only full payments allowed");
        pricePaid += msg.value;
        (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "Delivery did not work");
    }

    fallback () external {

    }
}