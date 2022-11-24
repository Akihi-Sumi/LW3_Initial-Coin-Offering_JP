const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  // 前のモジュールでデプロイしたCrypto Devs NFTコントラクトのアドレス
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;

  /*
   * ethers.jsのContractFactoryは、新しいスマートコントラクトをデプロイするために使用される抽象化です。
   * cryptoDevsTokenContractは、CryptoDevTokenコントラクトのインスタンス用のファクトリです。
   */
  const cryptoDevsTokenContract = await ethers.getContractFactory(
    "CryptoDevToken"
  );

  // コンタクトをデプロイ
  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(
    cryptoDevsNFTContract
  );

  await deployedCryptoDevsTokenContract.deployed();
  // デプロイされたコントラクトのアドレスを表示する
  console.log(
    "Crypto Devs Token Contract Address:",
    deployedCryptoDevsTokenContract.address
  );
}

// main関数を呼び出して、エラーがあればキャッチする。
main().then(() => process.exit(0)).catch((error) => {
  console.error(error);
  process.exit(1);
});