

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Straw{

    //User struct
    struct user{
        string name;
        friend[] friendList;
    }

    //friend struct
    struct friend{
        address pubkey;
        string name;
    }

    struct allUsers{
        string name;
        address accountAddress;
    }

    allUsers[] getAllUsers;

    //message struct
    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    }

    mapping(address => user) userList;
    mapping(bytes32 => message[]) messageList;

    //Check if user exists
    function checkUserExists(address pubkey) public view returns(bool){
        return bytes(userList[pubkey].name).length > 0;
    }

    // Create Account
    // use calldata to save gas fee
    function createAccount(string calldata name) external{ 
        require(!checkUserExists(msg.sender), "User already exists");
        require(bytes(name).length > 0, "UserName cannot be empty");
        userList[msg.sender].name = name;

        getAllUsers.push(allUsers(name, msg.sender));
    }

    // Get UserName
    function getUsername(address pubkey) external view returns(string memory){
        require(checkUserExists(pubkey), "User does not exist");
        return userList[pubkey].name;

    }

    // Add Friend
    function addFriend(address friend_key, string calldata name) external{
        require(checkUserExists(msg.sender), "User does not exist, Create an account first");
        require(checkUserExists(friend_key), "Lol your friend does not exist");
        require(msg.sender != friend_key, "You cannot add yourself as a friend");
        require (checkAlreadyFriend(msg.sender, friend_key)==false, "You are already friends");
        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    // Check Already Friends
    function checkAlreadyFriend(address pubkey, address friend_key) internal view returns(bool){
        if(userList[pubkey].friendList.length > userList[friend_key].friendList.length){
            address temp = pubkey;
            pubkey = friend_key;
            friend_key = temp;    
        }

        for(uint256 i=0; i<userList[pubkey].friendList.length; i++){
            if(userList[pubkey].friendList[i].pubkey == friend_key){
                return true;
            }
        }
        return false;
    }

    function _addFriend(address me, address friend_key, string memory name) internal{
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    function getMyFriendList() external view returns(friend[] memory){
        require(checkUserExists(msg.sender), "User does not exist, Create an account first");
        return userList[msg.sender].friendList;
    }

    function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if(pubkey1 < pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        }
        else return keccak256(abi.encodePacked(pubkey2, pubkey1)); 
    }

    function sendMessage(address friend_key, string calldata _msg) external{
        require(checkUserExists(msg.sender), "User does not exist, Create an account first");
        require(checkUserExists(friend_key), "Lol your friend does not exist");
        require(checkAlreadyFriend(msg.sender, friend_key), "You are not friends");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newmsg = message(msg.sender, block.timestamp, _msg);
        messageList[chatCode].push(newmsg);
    }

    function readMessage(address friend_key) external view returns(message[] memory){
        require(checkUserExists(msg.sender), "User does not exist, Create an account first");
        require(checkUserExists(friend_key), "Lol your friend does not exist");
        require(checkAlreadyFriend(msg.sender, friend_key), "You are not friends");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return messageList[chatCode];
    } 

    function getAllAppUsers() public view returns(allUsers[] memory){
        return getAllUsers;
    }
}
