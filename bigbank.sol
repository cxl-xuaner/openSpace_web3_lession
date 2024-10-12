// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

// 编写一个 BigBank 合约， 它继承自该挑战 的 Bank 合约，并实现功能：
// 要求存款金额 >0.001 ether（用modifier权限控制）
// BigBank 合约支持转移管理员
// 同时编写一个 Ownable 合约，把 BigBank 的管理员转移给Ownable 合约， 实现只有Ownable 可以调用 BigBank 的 withdraw().
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

contract Bank {
    mapping (address=>uint256) public accounts;
    address payable public owner;
    address[3] public rich3;
    constructor(){
        owner = payable(msg.sender);
    }
    modifier admin(){
        require(msg.sender==owner,"caller is not the owner");
        _;
    }
    receive() external payable virtual {
        updateInfo();  
    }
    // top3排序
    function _sort(address sender) internal {
        uint _value = accounts[sender];
        for(uint i=0; i<rich3.length; i++){
            if(rich3[i]==address(0) || accounts[rich3[i]]<_value){
                for(uint j=rich3.length-1; j>i; j--){
                    rich3[j] = rich3[j-1];
                }
                rich3[i]=sender;
                break;
            }
        }
    }

    //更新余额和排序入口函数
    function updateInfo() internal {
        accounts[msg.sender] += msg.value;
        _sort(msg.sender); //存款金额前三地址
    }

    //存入资金
    function deposit() public payable virtual {
        updateInfo();
    }

    //提取资金
    function withdraw(uint amount) public virtual admin{
        uint balance = address(this).balance;
        require(amount<=balance,"Insufficient balance");
        payable(msg.sender).transfer(amount);
    
    }

}


contract Ownable {
    address public owner;
    constructor (){
        owner = msg.sender;
    }
    modifier admin(){
        require(msg.sender==owner,"caller is not the owner");
        _;
    }
    // 修改管理员
    function changeOwner(address _address) external admin{
        require(_address!=address(0), "zero address is not allow");
        owner = _address;
    }

}

contract BigBank is Bank {
    Ownable public OwnableContract;
    //初始化Ownable合约
    constructor(address _OwnableAddress){
        OwnableContract = Ownable(_OwnableAddress);
    }
    // 最小存入门限
    modifier minDeposit {
        require(msg.value>0.001 ether,"deposit value need > 0.001 ether");
        _;
    }
    // 增加最低存入门限判断
    receive() external payable override minDeposit{
        // require(msg.value>0.001 ether,"deposit value need > 0.001 ether");
        updateInfo();  
    }
    // 更改管理员
    function changeOwner(address _address) external admin{
        require(_address!=address(0), "zero address is not allow");
        owner = payable(_address);
    }
    //存入资金-增加最低存入门限判断 
    function deposit() public payable override minDeposit{
        super.deposit();
    }

    //管理员提取资金
    function withdraw(uint amount) public override admin{
        require(msg.sender==OwnableContract.owner(), "caller is not the Ownable contract's owner"); //只有Ownable合约的拥有者才有权限调用withdraw函数
        super.withdraw(amount);
    
    }

}