// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply; 
    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowances; 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** decimals;
        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];

    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= _value,"ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        uint balances_amount = balances[_from];
        require(_value <= balances_amount, "ERC20: transfer amount exceeds balance");
        uint allowance_amount = allowances[_from][msg.sender];
        require(_value <= allowance_amount, "ERC20: transfer amount exceeds allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here
        return  allowances[_owner][_spender];

    }
}


contract TokenBank {
    mapping (address=>uint) public balance;
    address public owner;
    constructor (){
        owner = msg.sender;
    }
    // modifier onlyOwner(){
    //     require(owner==msg.sender, "only owner");
    //     _;
    // }

    function deposit(address _erc20, uint amount) external returns(bool){
        require(BaseERC20(_erc20).balanceOf(msg.sender) >= amount, "deposit amount exceeds balance");
        BaseERC20(_erc20).transfer(address(this), amount);
        balance[msg.sender] += amount;
        return true;
    }

    function withdraw(address _erc20, uint amount) external returns(bool){
        require(balance[msg.sender]>=amount, "withdraw amount exceeds balance");
        BaseERC20(_erc20).transfer(msg.sender, amount);
        balance[msg.sender] -= amount;
        return true;
    }
}