# 作业2
# 题目#2
# 实践非对称加密 RSA(编程语言不限)
# 1.先生成一个公私钥对
# 2.用私钥对符合 POW 4个开头的哈希值的“昵称 +nonce”进行私钥签名
# 3.用公钥验证
import hashlib
import random
import datetime
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization
from cryptography.exceptions import InvalidSignature

# 计算耗时
def calculate_time_cost(func,my_wechat_alias,length):
    """
    计算函数`func`的耗时。
    :param func: 要测量耗时的函数
    :return: 函数执行的耗时（秒）
    """
    print("*" * 50, "开始执行", "*" * 50)
    print(f'计算{length}个0开头hash耗时：')
    start_time = datetime.datetime.now()
    func(my_wechat_alias,length)
    end_time = datetime.datetime.now()
    elapsed_time = end_time - start_time
    cost_seconds = elapsed_time.total_seconds()
    print("*" * 50, "执行完毕,累计耗时%s秒" % cost_seconds, "*" * 50)

# 利用指定消息获取指定0数量开头长度的Nonce
def calculate_head(my_wechat_alias,length):
    sha256_hash = hashlib.sha256()
    nonce = 0
    while True:
        input_data = my_wechat_alias + str(nonce)
        sha256_hash.update(input_data.encode('utf-8'))
        result_hash_value = sha256_hash.hexdigest()
        if result_hash_value[0:length] == '0'*length:
            print('my_wechat_alias:',my_wechat_alias)
            print('nonce:',nonce)
            print('result_hash_value:',result_hash_value)
            return nonce
        nonce += 1

if __name__ == '__main__':
    # 生成 RSA 公私钥对
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )

    public_key = private_key.public_key()
    print("public_key:",public_key)

    # 要签名的消息
    length = 4
    my_wechat_alias = 'chenxiaolin'
    nonce = calculate_head(my_wechat_alias,length)
    message = (my_wechat_alias + str(nonce)).encode('utf-8')

    # 使用私钥对消息进行签名
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )

    print(f"签名: {signature.hex()}")

    # 使用公钥验证签名
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print("验证成功，签名有效！")
    except InvalidSignature:
        print("验证失败，签名无效！")
    
'''
本机结果：
public_key: <cryptography.hazmat.backends.openssl.rsa._RSAPublicKey object at 0x0000021E77ACA970>
my_wechat_alias: chenxiaolin
nonce: 31873
result_hash_value: 0000e28a666116cb9132fd47510fb2d801e2091e379b697202784caea15925ee
签名: 7fc7303b71f5318526bb6dac6914fe3b478cf0c5fb686e3b591f4e5f1c31995621418589d5a8768745dafe1d703d44a479f49022bfe0a6bb344b4aaa80232eccbd42ef9077cd3643d6e446d7abc6920a1ca7c2a5ea8392a8fa08fbc71a9c12b17bb4e1aca388947cf013bfccc728840ed4816b80539c7ccfc9c118bc702e29fa9b2da22d91770f44471c5dc99aa166fdbed447c682a8be846d7d5d078378390aeb2800dabbbbfafae19335ae3e62d95a6aaada50c50421ac88c7312b7a501a7ed0c7c618b9179689d3bf8a7ac33e146623f6400fc2078dc5d029f0466bb50203e9ac03dd0b8dd438d19798ec69b26d67ce893df269d50e805d67d51238d0dec7
验证成功，签名有效！
'''
