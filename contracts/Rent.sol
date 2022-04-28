// SPDX-License-Identifier: GPL-3.0
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//   
//                                                 
//      
//      
//
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//      @artist ::          stereoIII6.eth                                                                                                                                          //
//      @msg ::             stereoIII6.eth.chat                                                                                                                                     //
//      @github ::          stereoIII6                                                                                                                                              //
//                                                                                                                                                                                  //
//      @dev ::             stereoIII6.eth                                                                                                                                          //
//      @msg ::             stereoIII6.eth.chat                                                                                                                                     //
//      @github ::          stereoIII6                                                                                                                                              //
//                                                                                                                                                                                  //
//      @author ::          stereoIII6.eth                                                                                                                                          //
//      @msg ::             stereoIII6.eth.chat                                                                                                                                     //
//      @github ::          stereoIII6                                                                                                                                              //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                                                                                                                                                                                  //
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//      @title ::           safe contract                                                                                                                                           //
//      @description ::     Decentral Social Network Experiment                                                                                                                     //
//      @version ::         0.0.1                                                                                                                                                   //
//      @purpose ::         Bring real life into the Blockchain                                                                                                                     //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Rent is ERC20 {

    address[3] internal admins;
    mapping(address => uint256) internal adminId;
    mapping(address => mapping(uint256 => uint256)) internal releaseTime;
    mapping(address => uint256) internal releases;
    address[33] internal shareholders;
    uint256 internal shareCount;
    mapping(address => uint256) public shareId;
    uint256 public maxSupply;
    uint256 public pubSupply;
    uint256 public shareSupply;
    uint256 public poolSupply;
    uint256 internal digits;
    uint256 internal logCount;
    event Log(uint256 indexed _a, string _log, address _adr, uint256 _tmstmp); 
    modifier isAdmin(address _adr)
    {
        require(_adr == admins[0] || _adr == admins[1] || _adr == admins[2]);
        require(msg.sender == admins[0] || msg.sender == admins[1] || msg.sender == admins[2]);
        _;
    }
    constructor() ERC20("derental dao token", "DRNT")  
    {
        buyShare(0x5fA621cf6B13640F882992373b1E86F6901dC8A5);
        buyShare(0x823230d6458Cba58FFB8cb4D88Ba4DaCbF2C7263);
        admins = [payable(msg.sender),0x5fA621cf6B13640F882992373b1E86F6901dC8A5,0x823230d6458Cba58FFB8cb4D88Ba4DaCbF2C7263];
        adminId[msg.sender] = 0;
        adminId[0x5fA621cf6B13640F882992373b1E86F6901dC8A5] = 1;
        adminId[0x823230d6458Cba58FFB8cb4D88Ba4DaCbF2C7263] = 2;
        maxSupply = 999 * 10 ** 9;
        pubSupply = 336 * 10 ** 9;
        shareSupply = 330 * 10 ** 9;
        poolSupply = 333 * 10 ** 9;
        digits = 10**18;
        _mint(address(this),poolSupply);
    }
    function buyShare(address _adr) public payable returns(bool) // buy one of 33 shares for 50 ETH each
    {
        bool b = shareCount >= 2;
        if(b) require(msg.value == 50 * digits, "not enough value transferred");
        shareholders[shareCount] = _adr;
        shareId[_adr] = shareCount;
        shareCount += 1;
        if(b) emit Log(logCount, "new shareholder", msg.sender, block.timestamp);
        if(b) logCount += 1;
        distShareSupply(_adr);
        return true;
    }
    function distShareSupply(address _adr) internal returns(bool) // distribute sharesupply to shareholders
    {
        require(shareholders[shareId[_adr]] == _adr);
        require(shareCount <= 32);
        _mint(_adr,shareSupply / 33);
        emit Log(logCount, "share distributed", _adr, block.timestamp);
        logCount += 1;
        return true;
    }
    function ethSupply() public view returns(uint256)
    {
        return address(this).balance;
    }
    function timeNow() public view returns(uint256)
    {
        return block.timestamp;
    }
    function reLoop(address _adr) internal returns(bool)
    {
        bool ret = true;
        uint256 last = releaseTime[_adr][releases[_adr]];
        uint256 dif;
        if(releases[_adr] > 0) dif = block.timestamp - last;
        else dif = 0;
        emit Log(logCount, "time difference", msg.sender, dif);
        if(releases[_adr] > 0 &&  dif < 60 * 60 * 24 * 365) ret = false; // must be one month since last payout
        return ret;
    }
    function adminRelease(address payable _adr) public payable isAdmin(_adr) returns(bool)
    {
        require(address(this).balance >= 10*digits);
        require(releases[_adr] <= releases[admins[0]] + 1 || releases[_adr] <= releases[admins[1]] + 1 || releases[_adr] <= releases[admins[2]] + 1 );
        require(reLoop(_adr));
        releases[_adr] += 1;
        releaseTime[_adr][releases[_adr]] = block.timestamp;
        _adr.transfer(24 * digits);
        emit Log(logCount, "payment ordered by", msg.sender, block.timestamp);
        logCount += 1;
        emit Log(logCount, "payment released to", _adr, block.timestamp);
        logCount += 1;
        return true; 
    }


}
