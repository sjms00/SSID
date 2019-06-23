pragma solidity 0.4.25;
import "../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import '../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol';

contract TokenSSID is ERC721Token, Ownable {
  

    constructor () ERC721Token("SistemaSanitario", "SSID") public {}

/**
    * Custom accessor to create a unique token
    */
    function mintTo(address _to) public returns (uint256) {    
        uint _TokenId;
        _TokenId = _getNextTokenId();
        _mint(_to, _TokenId);
        return _TokenId;
    }
/**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
    function _getNextTokenId() private view returns (uint256) {
        return totalSupply().add(1); 
    }
}