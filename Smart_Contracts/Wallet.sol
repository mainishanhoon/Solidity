// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Wallet 
{
    address public Owner;
    mapping(address => uint) Balance;
    event Sent(address from, address to, uint Amount);
    event Minted(uint Amount);

    constructor()
    {   
        Owner = msg.sender;
    }

    modifier onlyOwner()
    {
        require(Owner == msg.sender, "Only the owner can perform this action");
        _;
    }

    function MintEther(address Receiver, uint Amount) public onlyOwner
    {
        require(Amount < 1e60, "Amount exceeds limit");
        Balance[Owner] -= Amount;
        Balance[Receiver] += Amount;
        emit Minted(Amount);
    }

    function SendEther(address Receiver, uint Amount) public payable
    {
        require(Amount <= Balance[msg.sender], "Insufficient Balance");
        require(Amount > 0, "Enter the Amount of Ether");
        require(Receiver != msg.sender, "Sender & Receiver cannot be Same");
        Balance[msg.sender] -= Amount;
        Balance[Receiver] += Amount;
        emit Sent(msg.sender, Receiver, Amount);
    }

    function ReceiveEther() public payable {
        Balance[Owner] += msg.value;
    }

    function ContractBalance() public view returns(uint)
    {
        return address(this).balance;
    }

    function CheckBalance(address _Check) external view returns(uint)
    {
        return Balance[_Check];
    }
}
