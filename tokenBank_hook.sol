// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenReceiver {
    function tokensReceived(
        address operator,
        address from, 
        address to, 
        uint256 value, 
        bytes calldata data
    ) external returns(bool);
}

contract BaseERC20{
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

    //判断address是否合约账户
    function isContract(address _addr) public view returns (bool) {
        return _addr.code.length > 0;
    }

    //带hook的transfer
    function transferWithCallback(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        success = transfer(_to, _value);
        if(success && isContract(_to)){
            bool rv = ITokenReceiver(_to).tokensReceived(msg.sender, msg.sender, _to, _value, "");
            require(rv, "no tokensReceived");
        }
        return success;
    }

    

}


contract TokenBank{
    mapping (address=>uint) public deposited;
    address public owner;
    BaseERC20 public BaseERC20Contract;
    constructor (address _tokenAddress){
        owner = msg.sender;
        BaseERC20Contract = BaseERC20(_tokenAddress);
    }
    // modifier onlyOwner(){
    //     require(owner==msg.sender, "only owner");
    //     _;
    // }

    function deposit(uint amount) external virtual returns(bool){
        require(BaseERC20Contract.balanceOf(msg.sender) >= amount, "deposit amount exceeds balance");
        bool success = BaseERC20Contract.transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom Failed");
        deposited[msg.sender] += amount;
        return success;
    }

    function withdraw(uint amount) external virtual returns(bool){
        require(deposited[msg.sender]>=amount, "withdraw amount exceeds balance");
        BaseERC20Contract.transfer(msg.sender, amount);
        deposited[msg.sender] -= amount;
        return true;
    }
}


// 继承 TokenBank 编写 TokenBankV2，支持存入扩展的 ERC20 Token，用户可以直接调用 transferWithCallback 将 扩展的 ERC20 Token 存入到 TokenBankV2 中。
// （备注：TokenBankV2 需要实现 tokensReceived 来实现存款记录工作）
contract TokenBankV2 is TokenBank{
    BaseERC20 public token;
    //TokenBankV2 继承自 TokenBank，所以在 TokenBankV2 的构造函数中，必须显式调用父合约的构造函数 TokenBank(_tokenAddress)，并传递 tokenAddress
    constructor (address _tokenAddress) TokenBank(_tokenAddress){
        token = BaseERC20(_tokenAddress);
    }
    function tokensReceived(address operator, address from, address to, uint _value, bytes calldata data) external returns (bool) {
        // tokensReceived 中需要添加判断: 
        require(msg.sender == address(token) , "invald token sender");  
        deposited[from] += _value;
        return true;
    }
}
