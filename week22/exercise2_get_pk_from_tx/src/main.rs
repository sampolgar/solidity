use ethers::prelude::*;
const RPC_URL: &str = "https://rpc.ankr.com/polygon";

// 1. get public key from transaction
// https://polygonscan.com/tx/0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec
// tx: 0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec
// 2. create arbitrary signature with script
// script takes in the public key and produces
//

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let tx: H256 = "0xf25e29a951681c6dc49db7697ba3cafe0574c131e919966519a5ba11293c33ec"
        .parse()
        .unwrap();
    let tx: Transaction = get_transaction_from_tx(tx).await;
    println!("{:?}", tx);
    match tx {
        Some(tx) => recover_public_key(tx)?,
        None => println!("no tx found"),
    }
    Ok(())
}

async fn get_transaction_from_tx(tx_hash: H256) -> Result<(), Box<dyn std::error::Error>> {
    let provider = Provider::try_from(RPC_URL)?;
    let tx: Option<Transaction> = provider.get_transaction(tx_hash).await?;
    Ok(())
}

fn recover_public_key(tx: Transaction) -> Result<(), Box<dyn std::error::Error>> {
    let tx_type_2: Option<ethers::types::U64> = Some(ethers::types::U64::from(2));
    let tx_type_0: Option<ethers::types::U64> = Some(ethers::types::U64::from(0));
    if tx.transaction_type == tx_type_2 {
        println!("tx is a contract creation");
    } else if tx.transaction_type == tx_type_0 {
        println!("tx is a contract call");
    } else {
        println!("not sure");
    }

    let tx_hash = tx.hash();
    let tx_hash_bytes: [u8; 32] = tx_hash.into();
    let msg_hash: [u8; 32] = ethers::utils::keccak256(&tx_hash_bytes);
    let msg_hash_str = hex::encode(msg_hash);
    println!("msg_hash: {:?}", msg_hash_str);
    let msg_bytes = hex::decode(msg_hash_str).unwrap();
    println!("msg_bytes: {:?}", msg_bytes);
    let recoveredPubKey = ethers::types::Signature::recover(&msg_bytes, &signature).unwrap();
    Ok(())
}

// fn return_public_key
// struct Signature {
//     r: ethers::types::U256,
//     s: ethers::types::U256,
//     v: ethers::types::U64,
// }
// let signature: Signature = Signature {
//     r: tx.r,
//     s: tx.s,
//     v: tx.v,
// };
g