// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaaSDAO {
    struct Task {
        uint id;
        string description;
        uint voteCount;
        bool completed;
    }

    address public owner;
    uint public subscriptionFee;
    uint public nextTaskId;
    mapping(address => bool) public subscribers;
    mapping(uint => Task) public tasks;
    mapping(uint => mapping(address => bool)) public votes;

    event Subscribed(address indexed user);
    event TaskProposed(uint indexed taskId, string description);
    event Voted(uint indexed taskId, address indexed voter);
    event TaskCompleted(uint indexed taskId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlySubscriber() {
        require(subscribers[msg.sender], "Not a subscriber");
        _;
    }

    constructor(uint _subscriptionFee) {
        owner = msg.sender;
        subscriptionFee = _subscriptionFee;
    }

    function subscribe() external payable {
        require(msg.value == subscriptionFee, "Incorrect subscription fee");
        subscribers[msg.sender] = true;
        emit Subscribed(msg.sender);
    }

    function proposeTask(string calldata description) external onlySubscriber {
        tasks[nextTaskId] = Task(nextTaskId, description, 0, false);
        emit TaskProposed(nextTaskId, description);
        nextTaskId++;
    }

    function vote(uint taskId) external onlySubscriber {
        require(!tasks[taskId].completed, "Task already completed");
        require(!votes[taskId][msg.sender], "Already voted");

        votes[taskId][msg.sender] = true;
        tasks[taskId].voteCount++;
        emit Voted(taskId, msg.sender);
    }

    function completeTask(uint taskId) external onlyOwner {
        require(tasks[taskId].voteCount > 0, "No votes for this task");
        tasks[taskId].completed = true;
        emit TaskCompleted(taskId);
    }

    function payForUpdate() external payable onlySubscriber {
        require(msg.value == subscriptionFee, "Incorrect fee for update");
        // Logic for providing the update can be added here
    }
}