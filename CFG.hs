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
-- Contextfree grammar datatype definition and it's helper functions for reading a printing it accordingly
module CFG where

-- Contextfree grammar datatype
data CFG = CFG {
    nonterminals :: [String],   -- List holding nonterminals, reffered to as ns (list of nonterminals) or n (nonterminal)
    terminals :: [String],      -- List holding terminals, reffered to as ts (list of terminals) or t (terminal)
    startSymbol :: Char,        -- Start symbol will always be a Char from ['A'..'Z']
    rules :: [(String, String)] -- List of rules in format: rules ⊂ ns X (ns U ts)*, will be reffered to as rs (rules) and r (single rule)
}

-- Functions to be utilized in CFG show function:
-- Format list of nonterminals or terminals into required output form - (["A", "B", "<CD>"] -> "A,B,<CD>") (ends with newline)
listToString :: [String] -> String
listToString symbols = (tail $ foldr (\x acc-> ',' : x ++ acc ) "\n" symbols)

-- Recursively format rules into required form (("<CD>", "a") -> "<CD>->a") (each rule on it's own row)
rulesToString :: [(String, String)] -> String
rulesToString [] = ""
rulesToString (r:rs) = '\n' : (fst r ++ "->" ++ snd r)  ++ (rulesToString rs)

-- Let the CFG type be instance of show according to required format
instance Show CFG where
    show (CFG {nonterminals=ns, terminals=ts, startSymbol=s, rules=rs} ) = (listToString ns) ++ (listToString ts) ++ s : rulesToString rs

-- Functions to be utilized in CFG read function:
-- Parse string with list of (non)terminals into list of strings
listParse :: String -> [String]
listParse symbols = foldr (\symbol symbolsNew -> if symbol == ',' then symbolsNew else (symbol : []) : symbolsNew) [] symbols

-- Parse rules into internal representation
rulesParse :: [String] -> [(String, String)]
rulesParse rs = foldr (\r rsNew -> (take 1 r, drop 3 r) : rsNew) [] rs

-- Let's have separate parsing function to get CFG datatype from a string
cfgRead :: String -> CFG
cfgRead stringCFG = CFG {nonterminals=(listParse $ cfg !! 0), terminals=(listParse $ cfg !! 1), startSymbol=((cfg !! 2)!! 0), rules=(rulesParse $ drop 3 cfg)}
    where cfg = lines stringCFG
