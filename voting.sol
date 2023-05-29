pragma solidity 0.8.18;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
    // variables
    uint winningProposalId;
    //structs
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
        }
    
    struct Proposal {
        string description;
        uint voteCount;
        }
    //tableau de propositions
    Proposal[] proposals;

    // enums
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
        }

    WorkflowStatus status;
    // une mapping des votants.
    mapping(address => Voter) voters;
    
    //event
    
    event VoterRegistered(address voterAddress); 

    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    event ProposalRegistered(uint proposalId);

    event Voted (address voter, uint proposalId);

// modifiers

    modifier isWhitelisted() {
        require(voters[msg.sender].isRegistered, "You are not in the whitelist, cannot proceed");
        _;
    }
     modifier withStatus(uint _status) {
        require(uint(status) == _status, "Impossible during this phase");
        _;
    }

    // functions
     function getVoter(address _address) external view isWhitelisted returns (Voter memory) {
        return voters[_address];
    }
    function getProposals() external view isWhitelisted returns(Proposal[] memory)  {
        return proposals;
    }
    function getStatus() external view isWhitelisted returns(WorkflowStatus) {
        return status;
    }
    function addVoter(address _address) external onlyOwner withStatus(0) {
        require(voters[_address].isRegistered != true, "This voter already exists");
        voters[_address].isRegistered = true;
        emit VoterRegistered(_address);
    }
    function startProposalRegistration() external onlyOwner withStatus(0) {
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, status);
    }
    function addProposal(string memory _description) external isWhitelisted withStatus(1) {
        require(bytes(_description).length > 0, "Cannot accept an empty proposal description");
        require(proposals.length < 100, 'Cannot accept more than 100 proposals');
        Proposal memory proposal;
        proposal.description = _description;
        proposals.push(proposal);
        emit ProposalRegistered(proposals.length-1);
    }
    function endProposalRegistration() external onlyOwner withStatus(1) {
        require(proposals.length >= 1, "There is no submitted proposal for now, cannot end this phase");
        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, status);
    }
     function startVotingSession() external onlyOwner withStatus(2) {
        status = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, status);
    }
     function setVote(uint _proposalId) external isWhitelisted withStatus(3) {
        require(!voters[msg.sender].hasVoted, "Already voted");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        emit Voted (msg.sender, _proposalId);
    }

    /// @notice Owner ends the voting phase
    /// @dev Owner ends the voting phase. Current status must be VotingSessionStarted. Emits WorkflowStatusChange
    function endVotingSession() external onlyOwner withStatus(3) {
        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, status);
    }

    /// @notice Owner tallies the final votes
    /// @dev Owner tallies the final votes. Current status must be VotingSessionEnded. Maximum 100 proposals (DoS). Emits WorkflowStatusChange
    function tallyVotes() external onlyOwner withStatus(4) {
        uint _winningProposalId;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > proposals[_winningProposalId].voteCount) {
                _winningProposalId = p;
            }
        }
        winningProposalId = _winningProposalId;
        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, status);
    }
}