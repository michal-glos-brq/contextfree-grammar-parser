                                    -- #####################################
                                    -- #@$%&            2022           &%$@#
                                    -- #!     FLP - Projekt BKG-2-CNF     !#
                                    -- #!           Michal Glos           !#
                                    -- #!            xglosm01             !#
                                    -- #!              __                 !#
                                    -- #!            <(o )___             !#
                                    -- #!             ( ._> /             !#
                                    -- #!              `---'              !#
                                    -- #@$%&                           &%$@#
                                    -- #####################################

-- This file provides:
-- Functions necessary to convert contextfree grammar without epsilon rules
-- into contextfree grammar without trivial rules
module CFGnonTrivial where

import qualified Data.Map as Map (Map, toList, fromList, insertWith, lookup)
import Data.List (nub, sort)
import CFG

-- Decide whether rule is trivial
isTrivialRule :: (String, String) -> Bool
isTrivialRule (_, prod) = (length prod) == 1 && (head prod) `elem` ['A'..'Z']

-- Filter out trivial rules, get MAP with nonterminals as keys and it's nontrivial products as values
getNonTrivialRules :: [(String, String)] -> [String] -> Map.Map String [String]
getNonTrivialRules rs ns = foldl insertRule nonTrivialRulesMap nonTrivialRules
    where
        nonTrivialRules = filter (\r -> not $ isTrivialRule r) rs                           -- Filter out trivial rules
        nonTrivialRulesMap = (Map.fromList $ (zip ns (cycle [[]]) :: [(String, [String])])) -- Create map with each nonterminal as key and [] as value
        insertRule = (\acc r -> Map.insertWith (++) (fst r) [(snd r)] acc)                  -- helper function to insert rules into MAP

-- Get trivial rules from rule set (from algorithm 4.5: N_A = {B | A ->* B} - Let's call it a trivial set for nonterminal A)
-- A.K.A. for all nonterminals, get all nonterminals to which the first nonterminal could be derived into
getTrivialSets :: [(String, String)] -> Map.Map String [String] -> Map.Map String [String]
getTrivialSets rs oldSet
    | oldSet == newSet = oldSet             -- Fixed point algorithm -> If the new value equals the old, we finished
    | otherwise = getTrivialSets rs newSet  -- If not equal, iterate once again
    where
        newSet = iterateFixedPoint oldSet   -- Compute the actual iteration of trivial sets

-- One iteration of fixed point algorithm (from algorithm 4.5: N_A = {B | A ->* B})
-- Apply the derivation with n+1 steps
iterateFixedPoint :: Map.Map String [String] -> Map.Map String [String]
iterateFixedPoint trivialSet = Map.fromList $ iterateNonTerminals (Map.toList trivialSet) trivialSet

-- Expand the rules for each nonterminal (sort and nub rules for easy comparing)
iterateNonTerminals :: [(String, [String])] -> Map.Map String [String] -> [(String, [String])]
iterateNonTerminals ns dict = foldr (\n acc -> (fst n, sort $ nub $ iterateProducts (snd n) dict) : acc) [] ns

-- For each one of trivial derivation from trivial set, apply it's derivation
-- When nonterminal A has B in it's trivial set and B has C, this function will assign B and C to trivial set of A
iterateProducts :: [String] -> Map.Map String [String] -> [String]
iterateProducts [] _ = []
iterateProducts (prod:prods) dict = case Map.lookup prod dict of
    Just list -> filter (\x -> (head x) `elem` ['A'..'Z']) list ++ iterateProducts prods dict
    Nothing -> iterateProducts prods dict

-- Function to ease inserting a rule into Map of trivial sets
conditionalInsert :: Map.Map String [String] -> (String, String) -> Map.Map String [String]
conditionalInsert trivialSet r
    | isTrivialRule r = Map.insertWith (++) (fst r) [(snd r)] trivialSet
    | otherwise = trivialSet

-- Generate new non trivial set of rules for whole contextfree grammar (from algorithm 4.5: P')
generateNonTrivialRules :: Map.Map String [String] -> Map.Map String [String] -> [(String, String)]
generateNonTrivialRules trivialSet nonTrivialRules = foldl getRules [] (Map.toList trivialSet)
    where
        getRules = (\rs n -> rs ++ (generateNonterminalRules nonTrivialRules n))

-- Generate non trivial rules for single nonterminal
-- For nonterminal A, get it's trivial set N_A. For each nonterminal from N_A, get it's right parts of nontrivial rules - [r1,r2,..].
-- Merge A with N_A's right parts of rules into a set of rules for nonterminal A - [(A, r1),(A, r2),..].
generateNonterminalRules :: Map.Map String [String] -> (String, [String]) -> [(String, String)]
generateNonterminalRules _ (_, []) = []
generateNonterminalRules nonTrivialRules (n, (prod:prods)) = case prodsNonTrivial of
    Just list -> map (\x -> (n, x)) list ++ generateNonterminalRules nonTrivialRules (n, prods)
    Nothing -> generateNonterminalRules nonTrivialRules (n, prods)
    where 
        prodsNonTrivial = (Map.lookup prod nonTrivialRules)

-- Parse the grammar into grammar with no trivial rules
parseToNonTrivial :: CFG -> CFG
parseToNonTrivial (CFG {nonterminals=ns, terminals=ts, startSymbol=s, rules=rs} ) = CFG {nonterminals=ns, terminals=ts, startSymbol=s, rules=rsNew}
    where
        trivialSet = foldl conditionalInsert (Map.fromList $ map (\n -> (n, [n])) ns) rs
        rsNew = generateNonTrivialRules (getTrivialSets rs trivialSet) (getNonTrivialRules rs ns)
