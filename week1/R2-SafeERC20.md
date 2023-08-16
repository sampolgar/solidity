# Why does the SafeERC20 program exist and when should it be used?

## SafeERC20 is a wrapper that handles failure conditions

used for contract to contract interactions with other ERC20 transfers i.e. contract1 calls contract2 using safetransferfrom

## Example

```
IERC20 hamsterToken = 0x1234..;
mapping (address => uint256) trades;

function unSafeSell(uint256 tokenValue){

    // Transfer token on token contract
    hamsterToken.TransferFrom(msg.sender, this, tokenValue);

    // the above will return true or false
    // if I forget to catch the false, I could log the below as a successful transaction

    trades[msg.sender] = trades[msg.sender].add(tokenValue);
}

function safeSell(uint256 tokenValue){

    // Transfer token on token contract
    hamsterToken.safeTransferFrom(msg.sender, this, tokenValue);

    // Add transfer to trades log
    trades[msg.sender] = trades[msg.sender].add(tokenValue);
}

```
