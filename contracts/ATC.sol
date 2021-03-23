pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract ATC {
    mapping(address => User) public userData;
    mapping(address => Drop[]) public userDrops;
    mapping(address => Slot[]) public userSlots;
    mapping(address => mapping(uint256 => Slot[])) public dropSlots;
    enum Role {ADMIN, USER}
    Role currentRole;

    enum DropStatus {OPEN, CLOSED}
    DropStatus dropStatus;

    enum SlotStatus {PENDING, SUCCESS, FAILED}
    SlotStatus slotStatus;

    struct User {
        string username;
        Role role;
    }

    struct Drop {
        string title;
        uint256 price;
        DropStatus dropStatus;
    }

    struct Slot {
        address customer;
        bool paidOut;
        SlotStatus slotStatus;
        string slotID;
        string title;
        uint256 price;
    }

    modifier adminOnly() {
        require(userData[msg.sender].role == Role.ADMIN, "Admins only!");
        _;
    }

    constructor(string memory _username) public {
        userData[msg.sender] = User(_username, Role.ADMIN);
    }

    function addUser(address _newUser, string memory _username)
        public
        adminOnly
    {
        userData[_newUser] = User(_username, Role.USER);
    }

    function register(string memory _username) public {
        userData[msg.sender] = User(_username, Role.USER);
    }

    function addDrop(string memory _title, uint256 _price) public {
        // userData[_newUser] = User(_username, Role.USER);
        userDrops[msg.sender].push(Drop(_title, _price, DropStatus.OPEN));
    }

    function buySlot(
        address _procurerAddress,
        uint256 _dropIndex,
        string memory _slotID,
        string memory _title
    ) public payable {
        require(
            msg.value >= userDrops[_procurerAddress][_dropIndex].price,
            "Please pay the exact price"
        );
        Slot memory newSlot = Slot(
            msg.sender,
            false,
            SlotStatus.PENDING,
            _slotID,
            _title,
            msg.value
        );
        dropSlots[_procurerAddress][_dropIndex].push(newSlot);
        userSlots[msg.sender].push(newSlot);
    }

    function getDrops() public view returns (Drop[] memory) {
        return userDrops[msg.sender];
    }

    function getSlots() public view returns (Slot[] memory) {
        return userSlots[msg.sender];
    }

    function getDropSlots(uint256 _dropIndex)
        public
        view
        returns (Slot[] memory)
    {
        return dropSlots[msg.sender][_dropIndex];
    }

    function searchProcurerDrops(address _procurer)
        public
        view
        returns (Drop[] memory)
    {
        return userDrops[_procurer];
    }
}
