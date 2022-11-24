// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // Crypto Devトークン1個の価格
    uint256 public constant tokenPrice = 0.001 ether;
    // 1回のNFTで10トークンを獲得できる
    // ERC20トークンはトークンの最小の額面で表現されるため、10 * (10 ** 18)と表現する必要があります。
    // デフォルトでは、ERC20トークンは最小の10^(-18)の額面を持っています。
    // つまり、(1)の残高を持つことは、実際には(10 ^ -18)のトークンに相当する。
    // 完全な1トークンを所有することは、小数点以下を考慮すると（10^18）トークンを所有することに相当します。
    // これに関する詳細は、Freshman Track Cryptocurrencyのチュートリアルに記載されています。
    uint256 public constant tokensPerNFT = 10 * 10**18;
    // Crypto Dev Tokenの最大供給数は10000個です。
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // CryptoDevsNFTコントラクトインスタンス
    ICryptoDevs CryptoDevsNFT;
    // どのtokenIdsが請求されたかを追跡するためのマッピング
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
    * @dev CryptoDevTokenの数 `amount` をミントする。
    * 必要条件:
    * - `msg.value`はtokenPrice *量と同じかそれ以上である必要があります。
    */
    function mint(uint256 amount) public payable {
        // okenPrice * amountと同等かそれ以上であるべきetherの値。
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        // トークンの合計 + 金額 <= 10000, そうでない場合はトランザクションを元に戻します。
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        // OpenzeppelinのERC20コントラクトから内部関数を呼び出す。
        _mint(msg.sender, amountWithDecimals);
    }

    /**
    * @dev 送信者が保有するNFTの数に応じたトークンをミントします。
    * 必要条件:
    * 送信者が所有するCrypto Dev NFTの残高が0より大きいこと。
    * 送信者が所有するすべてのNFTに対してトークンが請求されていないこと。
    */
    function claim() public {
        address sender = msg.sender;
        // 指定された送信者アドレスが保有する CryptoDev NFT の数を取得します。
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        // If the balance is zero, revert the transaction
        require(balance > 0, "You dont own any Crypto Dev NFT's");
        // amountは、未請求のtokenIdsの数を追跡する。
        uint256 amount = 0;
        // 残高をループして、トークン一覧の与えられた `index` にある `sender` が所有するトークン ID を取得します。
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            // tokenIdが未請求の場合、金額を増加させる。
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // すべてのトークンアイディが要求された場合、トランザクションを元に戻す。
        require(amount > 0, "You have already claimed all the tokens");
        // OpenzeppelinのERC20コントラクトから内部関数を呼び出す
        // 各NFTのミント（金額×10）トークン
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /**
    * @dev コントラクトに送られたETHとトークンをすべて引き出す
    * Requirements:
    * 接続されたウォレットは所有者のアドレスでなければなりません。
    */
    function withdraw() public onlyOwner {
    address _owner = owner();
    uint256 amount = address(this).balance;
    (bool sent, ) = _owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
    }

    // Etherを受信する関数。msg.dataは空でなければならない。
    receive() external payable {}

    // msg.data が空でないときにfallback関数が呼ばれる
    fallback() external payable {}
}