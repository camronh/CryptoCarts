//SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@api3/airnode-protocol/contracts/AirnodeClient.sol";

contract ExampleClient is AirnodeClient {
    mapping(address => User) public userData;
    mapping(address => Drop[]) public userDrops;
    mapping(string => Slot) public slots;
    enum Role {ADMIN, USER}
    Role currentRole;
    mapping(bytes32 => bool) public incomingFulfillments;
    mapping(bytes32 => bool) public fulfilledData;
    mapping(bytes32 => string) public slotIDs;

    enum DropStatus {OPEN, CLOSED}
    DropStatus dropStatus;

    enum SlotStatus {PENDING, SUCCESS, FAILED}
    SlotStatus slotStatus;

    struct User {
        string username;
        Role role;
        bool valid;
        string[] slotIDs;
    }
    User user;

    struct Drop {
        string title;
        uint256 price;
        DropStatus dropStatus;
        string[] slotIDs;
    }

    struct Slot {
        address customer;
        address procurer;
        bool paidOut;
        SlotStatus slotStatus;
        string slotID;
        string title;
        uint256 price;
    }
    Slot slot;

    modifier adminOnly() {
        require(userData[msg.sender].role == Role.ADMIN, "Admins only!");
        _;
    }

    modifier validOnly() {
        require(userData[msg.sender].valid, "Unauthorized!");
        _;
    }

    constructor(address airnodeAddress, string memory _username)
        public
        AirnodeClient(airnodeAddress)
    {
        user = User({
            username: _username,
            role: Role.ADMIN,
            valid: true,
            slotIDs: new string[](0)
        });
        userData[msg.sender] = user;

    }

    function register(string memory _username) public {
        require(!userData[msg.sender].valid, "Already made an account");
        user = User({
            username: _username,
            role: Role.USER,
            valid: true,
            slotIDs: new string[](0)
        });
        userData[msg.sender] = user;
    }

    function addDrop(string memory _title, uint256 _price) public validOnly {
        // userData[_newUser] = User(_username, Role.USER);
        Drop memory newDrop;
        newDrop.title = _title;
        newDrop.price = _price;
        newDrop.dropStatus = DropStatus.OPEN;
        userDrops[msg.sender].push(newDrop);
    }

    function buySlot(
        address _procurerAddress,
        uint256 _dropIndex,
        string memory _slotID,
        string memory _title
    ) public payable validOnly {
        require(
            msg.value >= userDrops[_procurerAddress][_dropIndex].price,
            "Please pay the exact price"
        );
        Slot memory newSlot = Slot({
            customer: msg.sender,
            procurer: _procurerAddress,
            paidOut: false,
            slotStatus: SlotStatus.PENDING,
            slotID: _slotID,
            title: _title,
            price: msg.value
        });

        Drop storage drop = userDrops[_procurerAddress][_dropIndex];
        drop.slotIDs.push(newSlot.slotID);

        User storage user = userData[msg.sender];
        user.slotIDs.push(newSlot.slotID);

        // userData[msg.sender].slotIDs.push(newSlot.slotID);
        slots[_slotID] = newSlot;
    }

    function getDrops() public view validOnly returns (Drop[] memory) {
        return userDrops[msg.sender];
    }

    function getUserSlotIDs() public view validOnly returns (string[] memory) {
        return userData[msg.sender].slotIDs;
    }

    function getUserData() public view validOnly returns (User) {
        return userData[msg.sender];
    }

    function searchProcurerDrops(address _procurer)
        public
        view
        returns (Drop[] memory)
    {
        return userDrops[_procurer];
    }

    function markSuccessful(string memory _slotID) public {
        // require(deals[dealIndex].paid == false, "Already Paid out!!");
        require(slots[_slotID].paidOut == false, "Already Paid Out!");
        slots[_slotID].slotStatus = SlotStatus.SUCCESS;
        slots[_slotID].paidOut = true;
        // payable(msg.sender).transfer(slots[_slotID].price);
    }

    function markFailed(string memory _slotID) public {
        // require(deals[dealIndex].paid == false, "Already Paid out!!");
        require(slots[_slotID].paidOut == false, "Already Paid Out!");
        slots[_slotID].slotStatus = SlotStatus.FAILED;
        slots[_slotID].paidOut = true;
        // payable(slots[_slotID].customer).transfer(slots[_slotID].price);
    }

    function makeRequest(
        bytes32 providerId,
        bytes32 endpointId,
        uint256 requesterInd,
        address designatedWallet,
        bytes calldata parameters,
        string calldata slotID
    ) external {
        bytes32 requestId = airnode.makeFullRequest(
            providerId,
            endpointId,
            requesterInd,
            designatedWallet,
            address(this),
            this.fulfill.selector,
            parameters
        );
        incomingFulfillments[requestId] = true;
        slotIDs[requestId] = slotID;
    }

    function fulfill(
        bytes32 requestId,
        uint256 statusCode,
        bool data
    ) external onlyAirnode() {
        require(incomingFulfillments[requestId], "No such request made");
        delete incomingFulfillments[requestId];
        if (statusCode == 0) {
            fulfilledData[requestId] = data;
            if (data) {
                markSuccessful(slotIDs[requestId]);
            } else {
                markFailed(slotIDs[requestId]);
            }
        }
    }
}
