// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// 编写一个 Bank 合约，实现功能：
// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户
// 请提交完成项目代码或 github 仓库地址。

contract Bank {
    mapping (address=>uint256) public account;
    address payable public owner;
    address[3] public rich3;
    constructor(){
        owner = payable(msg.sender);
    }
    modifier admin(){
        require(msg.sender==owner,"need admin");
        _;
    }
    receive() external payable {
        
    }
    // top3排序
    function _order(address sender) internal {
        uint _value = account[sender];
        for(uint i=0; i<rich3.length; i++){
            if(rich3[i]==address(0) || account[rich3[i]]<_value){
                for(uint j=rich3.length-1; j>i; j--){
                    rich3[j] = rich3[j-1];
                }
                rich3[i]=sender;
                break;
            }

        }

    }

    //存入资金
    function deposit() public payable {
        if(account[msg.sender] == 0){
            account[msg.sender] = msg.value;
        }else{
            account[msg.sender] += msg.value;
        }
        _order(msg.sender); //存款金额前三地址
    }

    //提取资金
    function withdraw(uint amount) public admin{
        uint balance = address(this).balance;
        require(amount<=balance,"Insufficient balance");
        payable(msg.sender).transfer(amount);
    
    } 


}