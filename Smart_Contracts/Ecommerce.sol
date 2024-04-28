// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

contract Ecommerce {

    struct Product
    {
        string Title;
        string Description;
        address payable Seller;
        uint ProductID;
        uint Price;
        address Buyer;
        bool Delivered;
    }

    uint Counter = 1;
    address payable Manager;
    bool Destroyed;
    Product[] public Products;
    event Registered(string Title, uint ProductID, address Seller);
    event Bought(uint ProductID, address Buyer);
    event Delivered(uint ProductID);

    constructor()
    {
        Manager = payable(msg.sender);
    }

    modifier isNotDestroyed
    { 
        require(!Destroyed,"Contract does not exist");
        _; 
    }

    function RegisterItem(string memory _Title, string memory _Description, uint _Price) public
    {
        require(_Price > 0, "Price should be Greater than zero");
        Product memory Item;
        Item.Title = _Title;
        Item.Description = _Description;
        Item.Price = _Price * 10**18;
        Item.Seller = payable(msg.sender);
        Item.ProductID = Counter;
        Products.push(Item);
        Counter++;
        emit Registered(_Title, Item.ProductID, msg.sender);
    }

    function Buy(uint _ProductID) payable public 
    {
        require(Products[_ProductID-1].Price == msg.value, "Please Pay the Exact Price");
        require(Products[_ProductID-1].Seller != msg.sender, "Sender Cannot be the Buyer");
        Products[_ProductID-1].Buyer = msg.sender;
        emit Bought(_ProductID, msg.sender);
    }

    function Delivery(uint _ProductID) public 
    {
        require(Products[_ProductID-1].Buyer == msg.sender, "Only Buyer can Confirm");
        Products[_ProductID-1].Delivered = true;
        Products[_ProductID-1].Seller.transfer(Products[_ProductID-1].Price);
        emit Delivered(_ProductID);
    }

    function destroy() public isNotDestroyed
    { 
        require(Manager==msg.sender,"Only Manager can Destroy this Contract"); 
        Manager.transfer(address(this).balance);
        Destroyed=true; 
    }

    fallback() external payable
    {
        payable(msg.sender).transfer(msg.value); 
    }

    receive() external payable {}
}
