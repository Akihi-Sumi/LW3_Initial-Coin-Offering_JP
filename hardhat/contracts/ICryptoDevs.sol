// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICryptoDevs {
    /**
     * @dev `所有者`が所有するトークン ID を、そのトークンリストの指定された `index` から取得する。
     *  `所有者``のすべてのトークンを列挙するには、 {balanceOf} と一緒に使用する。
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    /**
     * @dev 所有者``のアカウントにあるトークンの数を返す。
     */
    function balanceOf(address owner) external view returns (uint256 balance);
}