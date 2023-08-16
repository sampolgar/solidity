// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";
import "../lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol";
import "../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Receiver.sol";
import "../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Spender.sol";

contract NFTToken is ERC721, IERC1363Receiver, IERC1363Spender {
    using ERC165Checker for address;
    address owner;
    address _acceptedToken;
    uint tokenID = 1;

    constructor(address acceptedToken_) ERC721("TestNFT", "TNFT") {
        _acceptedToken = acceptedToken_;
    }

    event TokensReceived(
        address indexed operator,
        address indexed sender,
        uint256 amount,
        bytes data
    );
    event TokensApproved(address indexed sender, uint256 amount, bytes data);

    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        require(
            _msgSender() == address(_acceptedToken),
            "ERC1363Payable: acceptedToken is not message sender"
        );

        emit TokensReceived(spender, sender, amount, data);

        _transferReceived(spender, sender, amount, data);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    function _transferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(amount >= 0.5 ether, "send 0.5 ether");
        _mint(sender, tokenID);
        tokenID++;
    }

    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        require(
            _msgSender() == address(_acceptedToken),
            "ERC1363Payable: acceptedToken is not message sender"
        );

        emit TokensApproved(sender, amount, data);
        _approvalReceived(sender, amount, data);
        return IERC1363Spender.onApprovalReceived.selector;
    }

    function _approvalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(
            _msgSender() == address(_acceptedToken),
            "ERC1363Payable: acceptedToken is not message sender"
        );
        IERC1363(_acceptedToken).transferFromAndCall(
            sender,
            address(this),
            amount
        );
    }

    // function supportsInterface(
    //     bytes4 interfaceId
    // ) public view virtual override returns (bool) {
    //     return
    //         interfaceId == type(IERC1363Receiver).interfaceId ||
    //         interfaceId == type(IERC1363Spender).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }
}
