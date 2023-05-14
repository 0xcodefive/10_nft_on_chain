// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let i := 0
            } lt(i, len) {
            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)
                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)
                mstore(resultPtr, out)
                resultPtr := add(resultPtr, 4)
            }
            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            mstore(result, encodedLen)
        }
        return string(result);
    }
}

contract TheMatrixNftContract is ERC721Enumerable, IERC2981, Ownable {
    using Strings for uint256;

    uint64 public royaltyFee = 500;
    uint256 public MAX_SUPPLY = 99;
    uint256 publicSaleTokenPrice = 0.001 ether;

    event NewMint(address indexed, uint256);
    event Received(address indexed, uint256);

    function generateHTMLandSVG(string memory textFromAddr) internal pure returns (string memory Html, string memory Svg) {
        (string memory frst, string memory scnd) = splitText(textFromAddr);

        Html = string(abi.encodePacked(
            '<!DOCTYPE html> <html lang="en"> <head> <meta charset="UTF-8"> <style> html, body { width: 100%; height: 100%; margin: 0px; border: 0; overflow: hidden; display: block; } .c { opacity: 0; position: fixed; width: 100%; height: 100%; z-index: 9999; top: 0; } </style> </head> <body> <canvas id="canvas" class="c"></canvas> <script type="text/javascript" > var c = document.getElementById("canvas"); var ctx = c.getContext("2d"); c.height = window.innerHeight; c.width = window.innerWidth; ctx.canvas.width = window.innerWidth; ctx.canvas.height = window.innerHeight; var chinese = "', 
            textFromAddr, 
            '"; chinese = chinese.split(""); var font_size = 24; var columns = c.width/font_size; var drops = []; for(var x = 0; x < columns; x++) {drops[x] = 1; }; RGBToHex = function(r,g,b){ var bin = r << 16 | g << 8 | b; return "#" + (function(h){ return new Array(7-h.length).join("0")+h})(bin.toString(16).toUpperCase())}; var R = 0; var G = 255; var B = 0; var color = RGBToHex(R,G,B); var S = 0; function draw(){ctx.fillStyle = "rgba(" + S + "," + S + "," + S + ",.05)";ctx.fillRect(0, 0, c.width, c.height);ctx.fillStyle = color;ctx.font = font_size + "px courier new";for(var i = 0; i < drops.length; i++){var text = chinese[Math.floor(Math.random()*chinese.length)];ctx.fillText(text, i*font_size, drops[i]*font_size);if(drops[i]*font_size > c.height && Math.random() > 0.975){drops[i] = 0;}drops[i]++;}}; var op = 500; function opas(){if(op<999){c.style.opacity = (++op / 1000).toString();}}; setInterval(draw, 100); setInterval(opas, 60); var fsd = 1; function fs(){ if(font_size > 32){fsd = -1;}; if(font_size < 16) {fsd = 1;}; font_size+=fsd }; setInterval(fs, 33333); function randcolor(){ R += Math.floor(Math.random() * 11) - 5; if (R > 255) {R = 255;}; if (R < 0) {R = 0;}; G += Math.floor(Math.random() * 11) - 5; if (G > 255) {G = 255;}; if (G < 0) {G = 0;}; B += Math.floor(Math.random() * 11) - 5; if (B > 255) {B = 255;}; if (B < 0) {B = 0;}; color = RGBToHex(R,G,B); S += Math.floor(Math.random() * 7) - 3; if (S > 100) {S = 100;}; if (S < 0) {S = 0;};}; setInterval(randcolor, 333); </script> </body> </html>'
        ));
        Svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="margin:auto;background:#000000;display:block;z-index:1;position:relative" width="100%" height="100%" preserveAspectRatio="xMidYMid" viewBox="0 0 300 300"><script xmlns=""/> <defs> <pattern id="pid-0.7920078148149863" x="0" y="0" width="100%" height="100%" patternUnits="userSpaceOnUse"> <style type="text/css"> @keyframes ldp-matrix { 0% { opacity: 1; fill: #c5ff10;} 10% { opacity: 1; fill: #34ff00; } 90% { opacity: 0} 100% { opacity: 0} } text { animation: ldp-matrix 2s linear infinite; transform: scaleX(1); } </style> </pattern> </defs> <rect x="0" y="0" width="100%" height="100%" fill="url(#pid-0.7920078148149863)"/> <text style="fill:#00ff00;font-size:22px;font-family:courier new;" x="50%" y="30%" text-anchor="middle" alignment-baseline="middle">Welcome to the matrix</text> ',
            '<text style="fill:#00ff00;font-size:22px;font-family:courier new;" x="50%" y="50%" text-anchor="middle" alignment-baseline="middle">Mr. ',
            frst,
            '</text> ',
            '<text style="fill:#00ff00;font-size:22px;font-family:courier new;" x="50%" y="70%" text-anchor="middle" alignment-baseline="middle">',
            scnd,
            '</text> </svg>'
        ));
    }

    function splitText(string memory text) public pure returns (string memory, string memory) {
        uint256 length = bytes(text).length;
        uint256 halfLength = length / 2;
        
        bytes memory firstHalf = new bytes(halfLength);
        bytes memory secondHalf = new bytes(length - halfLength);
        
        for (uint256 i = 0; i < halfLength; i++) {
            firstHalf[i] = bytes(text)[i];
        }
        for (uint256 j = 0; j < length - halfLength; j++) {
            secondHalf[j] = bytes(text)[halfLength + j];
        }
        
        string memory firstHalfString = string(firstHalf);
        string memory secondHalfString = string(secondHalf);
        
        return (firstHalfString, secondHalfString);
    }

    function toString(bytes memory data) internal pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function htmlToImageURI(string memory html) internal pure returns (string memory) {
        string memory baseURL = "data:text/html;base64,";
        string memory htmlBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(html))));
        return string(abi.encodePacked(baseURL,htmlBase64Encoded));
    }

    function svgToImageURI(string memory svg) internal pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        address owner = ownerOf(tokenId);

        bytes memory addrBytes = abi.encodePacked(owner);
        string memory textFromAddr = toString(addrBytes);

        (string memory html, string memory svg) = generateHTMLandSVG(textFromAddr);

        string memory imageURIhtml = htmlToImageURI(html);
        string memory imageURIsvg = svgToImageURI(svg);

        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "Dynamic on-chain NFT The Matrix | id: ", uint2str(tokenId),"",
                                '", "description":"',
                                "Welcome to the matrix Mr. ", textFromAddr,"",
                                '", "attributes":"", "image":"', imageURIsvg,'", "animation_url":"', imageURIhtml,'"}'
                            )
                        )
                    )
                )
            );
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function mint() public payable {
        require(publicSaleTokenPrice <= msg.value, "Ether value sent is not correct");
        uint256 _currentSupply = totalSupply();
        require(_currentSupply < MAX_SUPPLY, "You reached max supply");
        emit NewMint(msg.sender, _currentSupply);
        _safeMint(msg.sender, _currentSupply);
    }
    
    constructor() ERC721("Dynamic on-chain NFT The Matrix", "TheMatrix") {
        _safeMint(msg.sender, 0);
    }

    /***************Royalty BGN***************/
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(tokenId), "query for nonexistent token");
        return (address(this), (salePrice * royaltyFee) / 10000);
    }    

    function setRoyaltyFee(uint64 fee) external onlyOwner {
        require (fee <= 5000, "fee is too high");
        royaltyFee = fee;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    function withdrawTokens(address _address) external onlyOwner {
        IERC20 token = IERC20(_address);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_msgSender(), balance);
    }

    receive() external payable {
        emit Received(_msgSender(), msg.value);
    }
    /***************Royalty END***************/
}