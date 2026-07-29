% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

-module(worm_mesh_consensus).

-export([new_vote_session/1, vote_append/3, 
         tally_votes/1, quorum_met/2]).

-record(vote_session, {
    record :: term(),
    sequence :: non_neg_integer(),
    votes = [] :: [boolean()],
    total_replicas :: non_neg_integer()
}).

new_vote_session(TotalReplicas) ->
    #vote_session{total_replicas = TotalReplicas, votes = []}.

vote_append(Session, VoterIndex, VotedYes) ->
    Votes = Session#vote_session.votes,
    NewVotes = [VotedYes | Votes],
    Session#vote_session{votes = NewVotes}.

tally_votes(Session) ->
    Votes = Session#vote_session.votes,
    YesCount = length([V || V <- Votes, V =:= true]),
    NoCount = length([V || V <- Votes, V =:= false]),
    {YesCount, NoCount}.

quorum_met(Session, QuorumSize) ->
    {YesCount, _} = tally_votes(Session),
    YesCount >= QuorumSize.
