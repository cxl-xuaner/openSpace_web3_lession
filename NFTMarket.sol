// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;

// 实现ERC20 扩展 Token 所要求的接收者方法 tokensReceived  ，在 tokensReceived 中实现NFT 购买功能。
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenReceiver {
    function tokensReceived(
        address operator,
        address from, 
        address to, 
        uint256 value, 
        bytes calldata data
    ) external returns(bool);
}

//实现ERC20 扩展 Token 所要求的接收者方法 tokensReceived  ，在 tokensReceived 中实现NFT 购买功能。
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

contract MyNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;

    // 需要显式传递初始所有者
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function createNFT(string memory tokenURI) public onlyOwner returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId); // 安全铸造新 NFT
        _setTokenURI(newItemId, tokenURI); // 设置 token 的元数据 URI
        tokenCounter++;
        return newItemId;
    }
}

contract NFTMarket is IERC721Receiver  {
    address public admin;
    mapping(address => mapping(uint => uint)) public listed; //nft address -> tokenid ->price
    mapping(address => mapping(uint => address)) public listedOwner; //nft address -> tokenid ->owner

    // struct listedNft {
    //     uint tokenId;
    //     uint priceETH;
    // }

    constructor (){
        admin = msg.sender;
    }
    //实现上架功能，NFT 持有者可以设定一个价格（需要多少个 Token 购买该 NFT）并上架 NFT 到 NFTMarket，上架之后，其他人才可以购买
    function list(address nftAddress, uint tokenId,  uint priceETH) external returns (bool) {
        // 1、验证调用者是否是该NFT的持有者
        address _owner = IERC721(nftAddress).ownerOf(tokenId);
        require(_owner == msg.sender, "not the owner");
        // 2、将检查是否获取授权
        bool isApproved = IERC721(nftAddress).getApproved(tokenId) == address(this) || IERC721(nftAddress).isApprovedForAll(msg.sender, address(this));
        require(isApproved, "not approved");
        // 3、检查是否已经重复上架
        require(listed[nftAddress][tokenId]==0 || listedOwner[nftAddress][tokenId]==address(0), "already listed");
        // 4、将用户 NFT转移到NFT市场
        IERC721(nftAddress).safeTransferFrom(msg.sender, address(this), tokenId, "");
        // 5、更新listed 和 listedOwner信息
        listed[nftAddress][tokenId] = priceETH;
        listedOwner[nftAddress][tokenId] = msg.sender;
        
        return true;

    }

    //普通的购买 NFT 功能，用户转入所定价的 ETH 数量，获得对应的 NFT
    function buyNFT(address nftAddress, uint tokenId) external payable returns (bool){
        // 1、查询NFT的价格
        uint priceETH = listed[nftAddress][tokenId];
        // 2、判断输入的价格是否满足要求
        require(msg.value / 1 ether == priceETH, "Insufficient amount");
        // 3、将资金转给卖家
        require(address(this).balance >= msg.value);
        address _owner = listedOwner[nftAddress][tokenId];
        (bool success,) = payable(_owner).call{value: msg.value}("");
        require(success, "transfer failed");
        // 4、将NFT发送给买家
        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId, "");
        // 5、更新listed 和 listedOwner信息
        delete listed[nftAddress][tokenId];
        delete listedOwner[nftAddress][tokenId];
        // listed[nftAddress][tokenId] = priceETH;
        // listedOwner[nftAddress][tokenId] = msg.sender;
        return true;

    }

    // 实现 onERC721Received 方法
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}

}