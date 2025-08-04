保险柜Logic：
{
    owner           slot[0]
    password        slot[1]
}
功能：
1.改变owner:需要输入密码

保险柜:
{
    owner           slot[0]
    logic           slot[1]
    deposites       slot[2]
    canWithdraw     slot[3]
}

功能:
1.存款。不需要条件
2.管理员可以将保险柜状态设置为打开。
3.取款。需要保险柜状态是打开的，同时保险柜里有钱。可以取走用户自己的钱。
4.fallback。可以delegatecall到logic合约。

思路：
1.先部署logic,再部署vault合约。
2.部署attacker合约。
3.attacker设置chanageOwner为自己
4.