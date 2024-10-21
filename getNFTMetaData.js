import { createPublicClient, http} from "viem";
import {mainnet} from 'viem/chains';



// 使用 Viem.sh 读取该 NFT 0x0483b0dfc6c78062b9e999a82ffb795925381415 合约信息：
// 读取 NFT 合约中指定 NFT 的持有人地址：See {IERC721-ownerOf}
// 读取指定NFT的元数据：tokenURI(uint256)returns(string)
// 要求直接提交实现该功能的 TS 文件内容，或者 Github 文件链接


const publicClient = createPublicClient({
    chain:mainnet,
    transport:http()
})

const NFTABI = [
{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
{"inputs":[{"internalType":"uint256","name":"_tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"}
];



// (1)// 读取 NFT 合约中指定 NFT 的持有人地址：See {IERC721-ownerOf}
const getHold = async function(NFTContract_address, id){
    try{
        const result = await publicClient.readContract({
            address: NFTContract_address,
            abi: NFTABI,
            functionName: 'ownerOf',
            args: [id]
        })
        console.log(`NFT合约:${NFTContract_address},id为:${id}的拥有者地址为:${result}`)
    }catch(error){
        console.log(`查询错误，错误原因为:${error}`);

    }
}


// (2)// 读取指定NFT的元数据：tokenURI(uint256)returns(string)
const getTokenURI = async function(NFTContract_address, id){
    try{
        const result = await publicClient.readContract({
            address: NFTContract_address,
            abi: NFTABI,
            functionName: 'tokenURI',
            args: [id]
        })
        console.log(`NFT合约:${NFTContract_address},id为:${id} 的tokenURI为:${result}`)
    }catch(error){
        console.log(`查询错误，错误原因为:${error}`);

    }
}

const NFTContract_address = '0x0483b0dfc6c78062b9e999a82ffb795925381415';
const id = 1;
getHold(NFTContract_address, id);
getTokenURI(NFTContract_address, id);

// 打印结果
// NFT合约:0x0483b0dfc6c78062b9e999a82ffb795925381415,id为:1的拥有者地址为:0x6897625C2Da7E985e9c22E0d7B27A960Fc81D1D2
// NFT合约:0x0483b0dfc6c78062b9e999a82ffb795925381415,id为:1 的tokenURI为:ipfs://QmY9wa5FssaBBhLyyC2r649rwfS7CcvH7NG5AJWepeDkGj/1.json




