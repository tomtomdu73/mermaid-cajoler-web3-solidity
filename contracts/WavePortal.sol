// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;
    string[] private arrayBadAnswers;
    string[] private arrayGoodAnswers;

    event NewWave(address indexed from, uint256 timestamp, string message, string answer, string status);

    struct Wave {
        address waver;
        string message;
        string answwer;
        uint256 timestamp;
        string status;
    }

    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
        /* Set the answer */
        arrayBadAnswers = [
            "Please do not interrupt me while I am ignoring you.",
            "I am busy right now, but I would be happy to ignore you some other time.",
            "I will ignore you so hard you will start to doubt your own existence.",
            "I am not saying I hate you, what I am saying is that you are literally the Monday of my life.",
            "Silence is golden. Duct tape is silver.",
            "Find your patience before I lose mine.",
            "Life is good, you should get one.", 
            "I am sorry while you were talking I was trying to figure where the hell you got the idea I cared.",
            "I never forget a face, but in your case, I will be glad to make an exception.",
            "My imaginary friend says that you need a therapist.",
            "Me pretending to listen should be enough for you.",
            "Sometimes I wish I was an octopus so I could slap eight people at once.",
            "You would be in good shape... if you ran as much as your mouth.",
            "Lead me not into temptation. I know the way.",
            "Zombies eat brains. You are safe.",
            "Shut your mouth when you are talking to me.",
            "I will try being nicer, if you try being smarter.",
            "You are giving me the silent treatment? Finally.",
            "Apparently rock bottom has a basement.",
            "Someday, you will go far. I hope you stay there."
        ];
        arrayGoodAnswers = [
            "My mind and body respond to your dirty talks so strongly",
            "Do it again and again because the I love the way you do it.",
            "Please wake me up with your tongue every morning.",
            "Your clothes would look nice on my bedroom floor.",
            "If you kiss my neck, I am not responsible for what happens next...",
            "You can stay but your clothes must go.",
            "Your pants bother me, take them 0FF.",
            "Respect me. Adore me. Dominate me.",
            "Stop undressing me with your eyes! Use your teeth."
        ];
    }

    function wave(string memory _message) public {

        string memory picked_answer;
        string memory status;

        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 15m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 7) {
            console.log("%s managed to seduce a mermaid!", msg.sender);

            /* select random answer from array */
            picked_answer = arrayGoodAnswers[seed % arrayGoodAnswers.length];
            status = "true";
            waves.push(Wave(msg.sender, _message, picked_answer, block.timestamp, status));

            uint256 prizeAmount = 0.000069 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        else{
            /* select random answer from array */
            picked_answer = arrayBadAnswers[seed % arrayBadAnswers.length];

            console.log("%s failed seducing the mermaids!", msg.sender);
            status = "false";
            waves.push(Wave(msg.sender, _message, picked_answer, block.timestamp, status));
        }

        emit NewWave(msg.sender, block.timestamp, _message, picked_answer, status);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}