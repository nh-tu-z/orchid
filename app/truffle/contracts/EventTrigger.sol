//SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Ownable.sol";

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

contract ItemManager is Ownable {
    enum SupplyChainState{Created, Paid, Deliveried}

    struct S_Item {
        Item _item;
        string _identifier;
        uint _itemPrice;
        SupplyChainState _state;
    }

    mapping(uint => S_Item) public items;
    uint itemIndex;

    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);

    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        items[itemIndex]._item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._identifier = _identifier;
        items[itemIndex]._itemPrice = _itemPrice;
        items[itemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(items[itemIndex]._item));
        itemIndex++;
    }

    function triggerPayment(uint _itemIndex) public payable onlyOwner {
        require(items[_itemIndex]._itemPrice == msg.value, "Oly full payments accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item is futher in the chain");
        items[_itemIndex]._state = SupplyChainState.Paid;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }

    function triggerDelivery(uint _itemIndex) public payable {
        require(items[_itemIndex]._state == SupplyChainState.Paid, "Item is futher in the chain");
        items[_itemIndex]._state = SupplyChainState.Deliveried;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
}