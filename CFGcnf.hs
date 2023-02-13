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
-- Functions necessary to convert contextfree grammar without trivial rules to contextfree grammar
-- in Chomsky's normal form according to algorithm from TIN 
module CFGcnf where

import Data.List (nub)
import CFG

-- From given rules, get new rules and nonterminals in Chomsky's normal form
getCnfRulesAndNonterminals :: [(String, String)] -> ([(String, String)], [String])
getCnfRulesAndNonterminals rs = (rsNew, nsNew) where
    rsNew = nub $ concat $ map parseRuleToCNF rs    -- This function could return duplicate rules, therefore nub is applied
    nsNew = getNonterminalsFromRules rsNew          -- From the new set of rules are read all (new and original) nonterminals

-- Is rule in one of allowed formats for CNF? (A->a or A->AA)-(nonterminal is expanded into 2 nonterminals or a single terminal symbol)
-- this - "(not (nGen || tGen))" controlls whether the product is sane, other expressions test the count of terminals and nonterminals
ruleAlreadyCNF :: (String, String) -> Bool
ruleAlreadyCNF (_, prod) =  (not (nGen || tGen)) && ((ts == 1 && ns == 0) || (ns == 2 && ts == 0))  where
    (nGen, tGen, ns, ts) = foldr getProdInfo (False, False, 0, 0) prod

-- Helper function to get information about rule's product (How much terminals and nonterminals it has and is it sane?)
-- It's applied to product string from right and gradually completes 4 element tuple with information about product
getProdInfo :: Char -> (Bool, Bool, Int, Int) -> (Bool, Bool, Int, Int)
getProdInfo c (startNonTerm, startTermNonTerm, ns, ts)
    | c == '\'' && notMultiCharSymbol = (False, True, ns, ts)               -- ' symbol means nonterminal from original terminal is being read (a')
    | c == '>' && notMultiCharSymbol = (True, False, ns, ts)                -- > symbol means composed nonterminal (from ts and ns) is being read (<AaA>)
    | lowerCase && notMultiCharSymbol = (False, False, ns, ts + 1)          -- a (lowercase symbol) when not multichar nonterminal is generating counts as terminal
    | upperCase && notMultiCharSymbol = (False, False, ns + 1, ts)          -- A (uppercase symbol) when not multichar nonterminal is generating counts as nonterminal
    | lowerCase && startTermNonTerm = (False, False, ns + 1, ts)            -- a with ' before (a') is considered a nonterminal
    | parsingMultiCharNonTerminal && c == '<' = (False, False, ns + 1, ts)  -- < when composed nonterminal (<AaA>) is being read resembles (with AaA> before) a nonterminal
    | parsingMultiCharNonTerminal = (True, False, ns, ts)                   -- any symbol when multichar nonterminal is being read and < still not found is considered a part of mulitchar nonterminal
    | otherwise = (startNonTerm, startTermNonTerm, ns, ts)                  -- This one would hopefully not be needed, do nothing - exception occured
    where
        parsingMultiCharNonTerminal = startNonTerm &&  (not startTermNonTerm)   -- <AaA> type nonterminal is being read, still did not stumble upon <
        notMultiCharSymbol = (not startTermNonTerm) && (not startNonTerm)       -- a' type nonterminal is being read, expecting lowercase letter, ' was already read
        upperCase = c `elem` ['A'..'Z']
        lowerCase = c `elem` ['a'..'z']

-- Get rule and parse it reculrsively into set of CNF rules
parseRuleToCNF :: (String, String) -> [(String, String)]
parseRuleToCNF (n, prod)
    -- Stop the recursion
    | stop = (n, prod) : []
    -- Cut the rule's product into two new nonterminals in format (A->aAaB) => (A->a'<AaB>)
    | recursive && generateTwoRules = rNew : sndRule : parseRuleToCNF (nNew, prodNew)
    -- The composed nonterminal is already of len 1, terminal should be converted into nonterminal though (A->aA) => (A->a'A)
    | generateTwoRules = sndRule : rNew : []
    -- Only new composed nonterminal to be generated - (A->AaAa) => (A->A<aAa>)
    | recursive = rNew : parseRuleToCNF (nNew, prodNew)
    | otherwise = [] -- Something got (should not though) wrong
    where
        stop = ruleAlreadyCNF (n, prod)
        prodFst = head prod                         -- First symbol of product -> If it's terminal, convert it into a nonterminal as of (a -> a')
        generateTwoRules = elem prodFst ['a'..'z']  -- If the conversion above should happen, second rule (sndRule) has to be generated a'->a
        sndRule = ((prodFst : "'", [prodFst]))
        prodNew = tail prod                         -- This would be the product of the new nonterminal
        -- New nonterminal from tail, could be (accordingly to CNF rules) one of those types - {a', A, <Aa>}
        nNew = if (length prodNew) == 1 then (if (head prodNew) `elem` ['a'..'z'] then prodNew ++ "'" else prodNew) else '<' : prodNew ++ ">"
        -- New product formatted according to Chomsky's normal form to contain just 2 nonterminals of following form - {a'<Aa>, A<Aa>, a'A, AA, a'a', Aa'}
        newProd = (if generateTwoRules then prodFst : "'" else [prodFst]) ++ nNew
        rNew = (n, newProd)                         -- Input rule parsed into Chomsky's normal form
        recursive = (last nNew) `elem` ['>', '\'']  -- Call this function recursively, generate new rule(s) for expandning the new right nonterminal

-- A set of rules is enough to get all nonterminals, this function returns a list of nonterminals from a list of rules
getNonterminalsFromRules :: [(String, String)] -> [String]
getNonterminalsFromRules rs = foldl (\rsNew r -> if (fst r) `elem` rsNew then rsNew else (fst r) : rsNew) [] rs

-- Parse the nontrivial contextfree grammar into Chomsky's normal form
parseToCNF :: CFG -> CFG
parseToCNF (CFG {nonterminals=_, terminals=ts, startSymbol=s, rules=rs} ) = CFG {nonterminals=nsNew, terminals=ts, startSymbol=s, rules=rsNew} where
    (rsNew, nsNew) = getCnfRulesAndNonterminals rs
