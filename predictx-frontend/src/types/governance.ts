export type ProposalState =
  | 'Pending'
  | 'Active'
  | 'Succeeded'
  | 'Defeated'
  | 'Queued'
  | 'Executed';

export type Proposal = {
  id: string;
  title: string;
  proposer: string;
  forVotes: number;
  againstVotes: number;
  abstainVotes: number;
  quorumBps: number;
  eta: string;
  state: ProposalState;
};
