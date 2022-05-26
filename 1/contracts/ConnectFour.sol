//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

import "hardhat/console.sol";

/// @title ConnectFour
/// @author Bloomtech
/// @notice Allows any two players to place a 50-50 bet on who will win a game of Connect Four.
/// @notice For info on the rules of Connect Four, see https://en.wikipedia.org/wiki/Connect_Four
/// @dev See the {Game} struct for details on how the board is represented
contract ConnectFour {
    enum Disc { Empty, Player1, Player2 }
    enum Status { NonExistent, Initialized, Started, BetWithdrawn }
    enum WinningDirection { LeftDiagonal, Up, RightDiagonal, Right }

    /// @notice struct to represent a Connect Four game between 2 opponents. Each opponent
    /// enters the game by sending the betAmount, so that each game will have a pool of 2 * betAmount
    /// @dev player1 is the address who called ConnectFour.initializeGame, and player2
    /// is the player that called ConnectFour.startGame
    /// @dev each board is comprised of 7 columns, 6 rows, and starts out with each Cell initialized
    /// to Disc.Empty. The board is a single array, and to get the correct disc given a column and row
    /// ID (which are 0-indexed), see ConnectFour.boardIndex. We represent a position in the board as a tuple of
    /// (column, row). The disc (0, 0) is in the bottom left of the board and the disc in the top left of
    /// the board has the coordinates (0, 5) and exists at index 35 in the board array
    ///
    /// See this ASCII grid below for the board and the indexes of different slots
    ///
    /// -------------------------
    /// |/35/  /  /  /  /  /41/|
    /// |/  /  /  /  /  /  /  /|
    /// |/  /  /  /  /  /  /  /|
    /// |/  /  /  /  /  /  /  /|
    /// |/  /  /  /  /  /  /  /|
    /// |/0 /  /  /  /  /  /6 /|
    /// -------------------------

    struct Game {
        address player1;  
        address player2;  
        Disc[42] board;    
        uint256 betAmount; 
        Status status;    
        bool isPlayer1Turn;
    }   

    event GameInitialized(
        uint256 gameId,
        address player1,
        uint256 betAmount
    );

    event GameStarted(
        uint256 gameId,
        address player2
    );

    event RewardClaimed(
        uint256 gameId,
        address winner,
        address recipient,
        uint256 rewardAmount
    );

    mapping(uint256 => Game) public games;
    uint256 public minBetAmount;
    uint256 public maxBetAmount;
    uint256 internal gameIdCounter = 0;

    constructor(uint256 _minBetAmount, uint256 _maxBetAmount) {
        minBetAmount = _minBetAmount;
        maxBetAmount = _maxBetAmount;
    }

    function initializeGame() external payable returns (uint256) {
        require(msg.value >= minBetAmount && msg.value <= maxBetAmount, "check bet amt");
        uint256 gameId = gameIdCounter;
        gameIdCounter++;
        Disc[42] memory board;  // side effect
        games[gameId] = Game(msg.sender, address(0x0), board, msg.value, Status.Initialized, true);
        emit GameInitialized(gameId, msg.sender, msg.value);
        return gameId;
    }

    /// @notice Start a that has already been initialized by player1. The caller of this function (player2)
    /// must send in the same amount of ETH as player1 sent in. Afterwards the Game has started, and players
    /// may call ConnectFour.playMove to place their discs
    /// @param _gameId the game's ID, returned when player1 called ConnectFour.initializeGame
    function startGame(uint256 _gameId) external payable {
    }

    /// @notice Place a disc in the given column with the given Game. player1 and player2 will take
    /// turns placing one of their discs in a column, where it will fall until it stays in the bottom-most
    /// slot or onto the bottom-most previously-placed disc. For more info on how to play Connect Four, see
    /// the wikipedia page https://en.wikipedia.org/wiki/Connect_Four
    /// @dev illegal moves will cause the transaction to revert, such as placing a disc out of bounds of the 7x6
    /// board, trying to place a disc in a column which is already full, or going out of turn
    /// @param _gameId the game's ID, returned when player1 called ConnectFour.initializeGame
    /// @param _col the index of the column to place a disc in, valid values are 0 through 6 inclusive
    function playMove(uint256 _gameId, uint256 _col) external {
    }

    /// @notice Withdraws the bet amounts of both players to the recipient for the given game when there exists
    /// a winning four-in-a-row of the caller's discs. The caller specifies the four-in-a-row by providing
    /// starting column and row coordinates, as well as a direction in which to look for the 4 winning discs
    /// @dev As an example, imagine there is a winning four-in-a-row at coordinates (0,0), (0,1), (0,2), (0,3).
    /// Then the following function arguments will correctly claim the reward:
    /// _startingWinDiscCol = 0, _startingWinDiscRow = 0, _direction = Up
    /// @dev Note: there exists a vulnerability in this contract that we will exploit in a later Sprint :D
    /// @param _gameId the game's ID, returned when player1 called ConnectFour.initializeGame
    /// @param _recipient the address who will receive the bet's reward ETH
    /// @param _startingWinDiscCol the column index of one of the two end chips of the four-in-a-row
    /// @param _startingWinDiscRow the row index of one of the two end chips of the four-in-a-row
    /// @param _direction one of 4 possible directions in which to move when verifying the four-in-a-row
    function claimReward(uint256 _gameId, address payable _recipient, uint256 _startingWinDiscCol, uint256 _startingWinDiscRow, WinningDirection _direction) external {
    }

    /// @notice Return the index of a disc in the board, given its column and row index (0-indexed)
    /// @dev this function will throw if the column or row are out of bounds
    /// @param _col the index of the column, valid values are 0 through 6 inclusive
    /// @param _row the index of the row, valid values are 0 through 5 inclusive
    /// @return the index of the board corresponding to these coordinates
    function boardIndex(uint256 _col, uint256 _row) public pure returns (uint256) {
        require (_col > 6 || _col < 0, "Column index out of range");
        require (_row > 5 || _row < 0, "Row index out of range");
        return (_row * 7 + _col);
    }
}
