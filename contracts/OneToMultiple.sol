//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract OneToMultiple {
    
    //events
    event TransferFailed(address to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //state variables
    address public owner; //Tells the address of the owner
    address public feeAddress;
    uint256 public fee;

    //struct
    struct ReceiverInfo {
        address _recipients;
        uint _value;
    }

    ReceiverInfo[] public _recipientList;

    //mapping of address to ether balance
    mapping(address => uint256) private _balances;
    
    // constructor 
    // @param _feeAddress, setting fee withdrawl address
    constructor(address _feeAddress, uint256 _fee){
        feeAddress = _feeAddress;
        fee = _fee;
        owner = msg.sender;
    }

    //modifiers
    // onlyOwner, checks for owner operations
    modifier onlyOwner {
        require(msg.sender==owner,"Only owner can call this function");
        _;
    }
    
    // collectFee, withdraws the accumulated fee.
    modifier collectFee {
        if(fee>0){
            require(msg.value>=fee,"insufficient fee sent");
            payable(feeAddress).transfer(fee);
        }
        _;
    }

    //add recipients
    function addRecipient(address _addr, uint amount) public {
        ReceiverInfo memory receiverInfos;
        receiverInfos._recipients = _addr;
        receiverInfos._value = amount;
        _recipientList.push(receiverInfos);

    }
    
    // function send ether from msg.sender 
    function sendOnetoMultipleAddr(address[] memory recipients, uint256[] memory values, bool revertOnfail)  public payable collectFee {
        uint totalSuccess = 0;
        for (uint256 i = 0; i < recipients.length; i++)
        {
            require(recipients.length < 200, "Maximum addresses allowed are only 200");
            require(recipients[i] != address(0),"One of the Address is Null");
            require(_balances[msg.sender]>(values[i]));
           (bool success,)= recipients[i].call{value:values[i],gas:3500}('');
           if(revertOnfail) {
               require(success,"One of the transfers failed");
           }
           else if(success==false) {
               emit TransferFailed(recipients[i],values[i]);
           }
           if(success) totalSuccess++;
        }
        
        require(totalSuccess>=1,"All transfers failed");
        returnExtraEth();
    }

    function returnExtraEth () internal {
        uint256 balance = address(this).balance;
        if (balance > 0){ 
            payable(msg.sender).transfer(balance); 
        }
    }

    function balanceOf() public view returns(uint) {
        return _balances[msg.sender];
    }
    
    function changeFee (uint256 _fee) external onlyOwner {
        fee = _fee;
    }
    
    //Sets the address of the owner
    function changeOwner(address _owner) external onlyOwner {
        owner = _owner;
    }
    
    //sets new owner address
    function changeFeeAddress (address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

}