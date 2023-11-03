// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

import '../contracts/IToken.sol';

contract AtmOasis is Ownable, ReentrancyGuard {
  address public treasuryAddress = 0x28fD43425999De0607A443d64fE21c54230911Bd;
  address public burnAddress = 0x28fD43425999De0607A443d64fE21c54230911Bd;
  mapping(uint256 => bool) public processedNonces;
  uint256 public nonce;
  IToken public token;
  bool public AtmActive = false;

  event Received(address from, address to, uint amount, uint date, uint nonce);
  event Fund(address from, uint amount);

  constructor(address _token) {
    token = IToken(_token);
  }

  receive() external payable {
    emit Fund(msg.sender, msg.value);
  }

  function setToken(address _tokenAddress) external onlyOwner {
    token = IToken(_tokenAddress);
  }

  function withdrawOasis(address _address, uint256 _amount) external onlyOwner {
    uint256 balance = token.balanceOf(address(this));
    require(balance >= _amount, 'Amount is too high');
    token.transfer(_address, _amount);
  }

  function withdraw(address _address) external payable onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, 'Amount is too high');
    payable(_address).transfer(balance);
  }

  function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
    treasuryAddress = _treasuryAddress;
  }

  function setBurnAddress(address _burnAddress) external onlyOwner {
    burnAddress = _burnAddress;
  }

  function setAtmActive() external onlyOwner {
    AtmActive = !AtmActive;
  }

  function tokenTransfer(uint256 amount) external payable nonReentrant {
    require(AtmActive, 'Atm is not currently active');
    require(token.balanceOf(msg.sender) >= amount, 'Insufficent Balance');
    bool treasury = token.transferFrom(msg.sender, treasuryAddress, amount / 2);
    require(treasury, 'Token transfer from user failed');
    bool burn = token.transferFrom(msg.sender, burnAddress, amount / 2);
    require(burn, 'Token transfer from user failed');
    emit Received(msg.sender, address(this), amount, block.timestamp, nonce);
    nonce++;
  }
}
