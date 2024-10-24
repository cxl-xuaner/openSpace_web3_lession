import hashlib
import random
import datetime

# 计算生成指定0数量开头的SHA256Hash结果需要花费的时间
def calculate_time_cost(func,*args):
    """
    计算函数`func`的耗时。
    :param func: 要测量耗时的函数
    :return: 函数执行的耗时（秒）
    """
    print("*" * 50, "开始执行", "*" * 50)
    print(f'计算{length}个0开头hash耗时：')
    start_time = datetime.datetime.now()
    func(args)
    end_time = datetime.datetime.now()
    elapsed_time = end_time - start_time
    cost_seconds = elapsed_time.total_seconds()
    print("*" * 50, "执行完毕,累计耗时%s秒" % cost_seconds, "*" * 50)

def calculate_head(args):
    """
    
    """
    my_wechat_alias = args[0]
    length = args[1]
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
    length = 4
    my_wechat_alias = 'chenxiaolin'
    calculate_time_cost(calculate_head,my_wechat_alias,length)
    length = 5
    calculate_time_cost(calculate_head,my_wechat_alias,length)

'''
本机计算结果
************************************************** 开始执行 **************************************************
计算4个0开头hash耗时：
my_wechat_alias: chenxiaolin
nonce: 31873
result_hash_value: 0000e28a666116cb9132fd47510fb2d801e2091e379b697202784caea15925ee
************************************************** 执行完毕,累计耗时0.060805秒 **************************************************
************************************************** 开始执行 **************************************************
计算5个0开头hash耗时：
my_wechat_alias: chenxiaolin
nonce: 758915
result_hash_value: 00000823be03ca781de2332fdc4db063453c3356483f5593088a9778dfce0ea9
************************************************** 执行完毕,累计耗时1.125825秒 **************************************************

'''
