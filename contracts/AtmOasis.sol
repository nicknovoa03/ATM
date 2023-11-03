// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '../contracts/IToken.sol';

contract AtmOasis is Ownable, ReentrancyGuard {
  address public treasuryAddress = 0x5cb954EEcf438bcC958318CDBbD909728Ab86370;
  address public burnAddress = 0x000000000000000000000000000000000000dEaD;
  mapping(uint256 => bool) public processedNonces;
  uint256 public nonce;
  IToken public token;
  bool public atmActive = false;
  bool public trasuryActive = true;
  bool public burnActive = true;
  uint public treasuryAmount = 2;
  uint public burnAmount = 2;
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
    atmActive = !atmActive;
  }

  function setTreasuryActive() external onlyOwnerOrManager {
    trasuryActive = !trasuryActive;
  }

  function setBurnActive() external onlyOwnerOrManager {
    burnActive = !burnActive;
  }

  function setTreasuryAmount(uint _treasuryAmount) external onlyOwnerOrManager {
    treasuryAmount = _treasuryAmount;
  }

  function setBurnAmount(uint _burnAmount) external onlyOwnerOrManager {
    burnAmount = _burnAmount;
  }

  function tokenTransfer(uint256 amount) external payable nonReentrant {
    require(atmActive, 'Atm is not currently active');
    require(token.balanceOf(msg.sender) >= amount, 'Insufficent Balance');
    if (trasuryActive) {
      bool treasury = token.transferFrom(msg.sender, treasuryAddress, amount / treasuryAmount);
      require(treasury, 'Token transfer from user failed');
    }
    if (burnActive) {
      bool burn = token.transferFrom(msg.sender, burnAddress, amount / burnAmount);
      require(burn, 'Token transfer from user failed');
    }
    emit Received(msg.sender, address(this), amount, block.timestamp, nonce);
    nonce++;
  }
}
