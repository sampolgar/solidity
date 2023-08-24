use ethers::prelude::*;
use serde::Serialize;
use std::os::macos::raw;
const RPC_URL: &str = "https://rpc.ankr.com/polygon";

//adapted from here: https://gist.github.com/junomonster/d0c8b6820f00caf81e421ab741b3bbe8

// 1. get public key from transaction
// https://polygonscan.com/tx/0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec
// tx: 0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec
// 2. create arbitrary signature with script
// script takes in the public key and produces
//

//
// we want to get the public key from the transaction
// first we get the transaction from the transaction hash
// second we

//functions
// get_tx_from_tx_hash
// arg: transaction hash
// res: transaction object

// get_signature_from_tx
// arg: tx_obj
// res: signature object stuct(r, s, v)

// get_public_key_from_signature
// arg: signature object
// res: public key
// operations 1)

// #[derive(Default)]
// #[derive(Serialize)]
struct TransactionType2 {
    nonce: ethers::types::U256,
    to: ethers::types::Address,
    from: ethers::types::Address,
    input: ethers::types::Bytes,
    value: ethers::types::U256,
    transaction_type: ethers::types::U64,
    chain_id: ethers::types::U256,
}
//gaslimit
//maxfeepergas
//maxpriorityfee

//option 1 -> get a message and signature
//0xa2b0dbab8a435b11de83bbbc6dffb7661d6ffc7980d7c5d6f911dab2afc35812
// current: 0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let tx_hash: H256 = "0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec"
        .parse()
        .unwrap();
    //first
    // get_msg_and_sig(tx_hash).await?;

    //second
    get_public_key(tx_hash).await?;
    Ok(())
}

// option 2 - get the public key from the transaction
async fn get_msg_and_sig(tx_hash: H256) -> Result<(), Box<dyn std::error::Error>> {
    let provider = Provider::try_from(RPC_URL)?;
    //get tx from tx hash (get tx hash from etherscan/polygonscan)
    let tx: Option<Transaction> = provider.get_transaction(tx_hash).await?;

    //get signature from tx
    match tx {
        Some(tx) => {
            let signature = ethers::core::types::Signature {
                r: tx.r,
                s: tx.s,
                v: tx.v.low_u64(),
            };

            let tx_tx = TransactionType2 {
                nonce: tx.nonce,
                to: tx.to.unwrap_or(Address::zero()),
                from: tx.from,
                value: tx.value,
                input: tx.input,
                transaction_type: tx.transaction_type.unwrap_or(U64::zero()),
                chain_id: tx.chain_id.unwrap_or(U256::zero()),
            };

            println!("{:?} {:?} {:?}", signature.r, signature.s, signature.v);
            println!("{:?}", tx_tx.input);
            //do something
        }
        None => println!("No transaction found"),
    }

    Ok(())
}

async fn get_public_key(tx_hash: H256) -> Result<(), Box<dyn std::error::Error>> {
    let provider = Provider::try_from(RPC_URL)?;
    //get tx from tx hash (get tx hash from etherscan/polygonscan)
    let tx: Option<Transaction> = provider.get_transaction(tx_hash).await?;

    //get signature from tx
    match tx {
        Some(tx) => {
            println!("{:?}", tx);
            let signature = ethers::core::types::Signature {
                r: tx.r,
                s: tx.s,
                v: tx.v.low_u64(),
                // v: 1,
            };
            println!("{:?}", signature);

            //const rstransactionHash = await ethers.utils.resolveProperties(transactionHashData)
            //returns a promise to the data
            // let tx_tx = TransactionType2 {
            //     nonce: tx.nonce,
            //     to: tx.to.unwrap_or(Address::zero()),
            //     from: tx.from,
            //     value: tx.value,
            //     input: tx.input.clone(),
            //     transaction_type: tx.transaction_type.unwrap_or(U64::zero()),
            //     chain_id: tx.chain_id.unwrap_or(U256::zero()),
            // };

            // println!("{:?} {:?} {:?}", signature.r, signature.s, signature.v);
            // println!("{:?}", tx_tx.input);

            //const raw = ethers.utils.serializeTransaction(rstransactionHash) // returns RLP encoded transactionHash
            let rlp_encoded_tx_hex_bytes: Bytes = ethers::types::Transaction::rlp(&tx);
            // println!("{:?}", rlp_encoded_tx_hex_bytes);
            //Bytes(0x02f9079081898085174876e800856045d782b6830700e58080b907346080604052600080546001600160a01b031916700ccc7439f4972897ccd70994123e0921bc17905534801561003357600080fd5b506106f1806100436000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806304989798146100465780634125fcce1461005b5780635f35c0921461008b575b600080fd5b6100596100543660046105e4565b6100c9565b005b60005461006e906001600160a01b031681565b6040516001600160a01b0390911681526020015b60405180910390f35b6100b9610099366004610533565b805160208183018101805160018252928201919093012091525460ff1681565b6040519015158152602001610082565b600061014185856040516020016100e1929190610660565b60408051601f1981840301815282825280516020918201207f19457468657265756d205369676e6564204d6573736167653a0a33320000000084830152603c8085019190915282518085039091018152605c909301909152815191012090565b600054604080516020601f87018190048102820181019092528581529293506001600160a01b039091169161019391869086908190840183828082843760009201919091525086939250506102579050565b6001600160a01b0316146101ee5760405162461bcd60e51b815260206004820152601360248201527f7369676e6174757265206e6f742076616c69640000000000000000000000000060448201526064015b60405180910390fd5b60018383604051610200929190610650565b9081526040519081900360200190205460ff161561021d57600080fd5b6001808484604051610230929190610650565b908152604051908190036020019020805491151560ff199092169190911790555050505050565b6000806000610266858561027b565b91509150610273816102c1565b509392505050565b6000808251604114156102b25760208301516040840151606085015160001a6102a68782858561042d565b945094505050506102ba565b506000905060025b9250929050565b60008160048111156102d5576102d561068f565b14156102de5750565b60018160048111156102f2576102f261068f565b14156103405760405162461bcd60e51b815260206004820152601860248201527f45434453413a20696e76616c6964207369676e6174757265000000000000000060448201526064016101e5565b60028160048111156103545761035461068f565b14156103a25760405162461bcd60e51b815260206004820152601f60248201527f45434453413a20696e76616c6964207369676e6174757265206c656e6774680060448201526064016101e5565b60038160048111156103b6576103b661068f565b141561042a5760405162461bcd60e51b815260206004820152602260248201527f45434453413a20696e76616c6964207369676e6174757265202773272076616c60448201527f756500000000000000000000000000000000000000000000000000000000000060648201526084016101e5565b50565b6000807f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a083111561046457506000905060036104e8565b6040805160008082526020820180845289905260ff881692820192909252606081018690526080810185905260019060a0016020604051602081039080840390855afa1580156104b8573d6000803e3d6000fd5b5050604051601f1901519150506001600160a01b0381166104e1576000600192509250506104e8565b9150600090505b94509492505050565b60008083601f84011261050357600080fd5b50813567ffffffffffffffff81111561051b57600080fd5b6020830191508360208285010111156102ba57600080fd5b60006020828403121561054557600080fd5b813567ffffffffffffffff8082111561055d57600080fd5b818401915084601f83011261057157600080fd5b813581811115610583576105836106a5565b604051601f8201601f19908116603f011681019083821181831017156105ab576105ab6106a5565b816040528281528760208487010111156105c457600080fd5b826020860160208301376000928101602001929092525095945050505050565b600080600080604085870312156105fa57600080fd5b843567ffffffffffffffff8082111561061257600080fd5b61061e888389016104f1565b9096509450602087013591508082111561063757600080fd5b50610644878288016104f1565b95989497509550505050565b8183823760009101908152919050565b60208152816020820152818360408301376000818301604090810191909152601f909201601f19160101919050565b634e487b7160e01b600052602160045260246000fd5b634e487b7160e01b600052604160045260246000fdfea2646970667358221220deea54fa1a454f8490377164cbcdbbb3d751c4d425cb3d52d301450aa166512c64736f6c63430008070033c080a0a6047212f38d40142e7271bfb75cf8c601f64be37f08a9a3ca6c797d48d773dba06af5744aa60dc962202eb641c1c94126589355706812e9602c435cc09d160dc9)

            let msg_binary_hash: [u8; 32] = ethers::utils::keccak256(rlp_encoded_tx_hex_bytes);
            // println!("{:?}", msg_binary_hash);
            //[242, 94, 41, 169, 81, 104, 28, 109, 196, 157, 183, 105, 123, 163, 202, 254, 5, 116, 193, 49, 233, 25, 150, 101, 25, 165, 186, 17, 41, 60, 51, 236]

            let address = ethers::types::Signature::recover(&signature, msg_binary_hash);
            println!("address {:?}", address);

            //
            //
        }
        None => println!("No transaction found"),
    }

    Ok(())
}
