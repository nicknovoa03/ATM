// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '../contracts/IToken.sol';

contract AtmOasis is Ownable, ReentrancyGuard {
  address public treasuryAddress = 0xcFf2045c2a164cbF6c5d01aDd95A5E518E3e8B07;
  address public burnAddress = 0xcFf2045c2a164cbF6c5d01aDd95A5E518E3e8B07;
  mapping(uint256 => bool) public processedNonces;
  uint256 public nonce;
  IToken public token;
  bool public AtmActive = false;
  address manager;

  event Received(address from, address to, uint amount, uint date, uint nonce);
  event Fund(address from, uint amount);

  constructor(address _token) {
    token = IToken(_token);
    manager = msg.sender;
  }

  modifier onlyOwnerOrManager() {
    require(owner() == _msgSender() || manager == _msgSender(), 'Caller is not the owner or manager');
    _;
  }

  function setManager(address _manager) external onlyOwner {
    manager = _manager;
  }

  receive() external payable {
    emit Fund(msg.sender, msg.value);
  }

  function setToken(address _tokenAddress) external onlyOwnerOrManager {
    token = IToken(_tokenAddress);
  }

  function withdrawOasis(address _address, uint256 _amount) external onlyOwnerOrManager {
    uint256 balance = token.balanceOf(address(this));
    require(balance >= _amount, 'Amount is too high');
    token.transfer(_address, _amount);
  }

  function withdrawEth(address _address) external payable onlyOwnerOrManager {
    uint256 balance = address(this).balance;
    require(balance > 0, 'Amount is too high');
    payable(_address).transfer(balance);
  }

  function setTreasuryAddress(address _treasuryAddress) external onlyOwnerOrManager {
    treasuryAddress = _treasuryAddress;
  }

  function setBurnAddress(address _burnAddress) external onlyOwnerOrManager {
    burnAddress = _burnAddress;
  }

  function setAtmActive() external onlyOwnerOrManager {
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
