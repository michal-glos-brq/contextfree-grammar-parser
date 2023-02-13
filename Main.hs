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
-- Main module controlling the whole program
import System.Environment (getArgs)
import System.Directory (doesFileExist)
import CFGcnf
import CFGnonTrivial
import CFG

-- Main function reading, parsing and printing CFG in required form
main :: IO ()
main = do
    args <- getArgs     -- Read CLI arguments
    if argsCorrect args -- Decide whether provided arguments are in correct format
        then do
            cfgString <- readInput args             -- Read input grammar as string
            let flag = getFlag args                 -- Get the flag determining the operation to be executed
            let internalCFG = cfgRead cfgString     -- And parse the grammar from string to it's own datatype from CFG module
            case flag of    -- Actually parse the grammar to one of requested forms
                "-i" -> putStrLn $ show internalCFG
                "-1" -> putStrLn $ show $ parseToNonTrivial internalCFG
                "-2" -> putStrLn $ show $ parseToCNF $ parseToNonTrivial internalCFG
                _    -> putStrLn help
        else putStrLn $ "Error!\n  Please, provide correct arguments.\n\n" ++ help

-- "Variable" holding the String with cli help message
help :: String
help = "flp (-i|-1|-2) [CFG_path]\n\n\
        \This program gets an CFG defined in a file (specifiy path as CLI arg) or provided to stdin\n\
        \  and parses it according to one of following flags which are mutually exclusive:\n\
        \    -i: Parse CFG into internal representation and print it as it is.\n\
        \    -1: Parse CFG into equivalent CFG without trivial rules.\n\
        \    -2: Parse CFG into equivalent CNF CFG.\n"

-- Check whether CLI arguments are correct
-- here, the -h flag is mentioned. When provided, help would be written out as if the args would be incorrect, the incorrect args error is not raised though
-- Flags are mutually exclusive, so exactly one flag is required, possibly a path to a file containing cfg
argsCorrect :: [String] -> Bool
argsCorrect args = (foldr flagDetector (0 :: Int) args) == 1 && (length args) `elem` [1,2]
    where
        acceptableFlags = ["-h", "-i", "-1", "-2"]
        -- When folded over a args list, count flags present in CLI args from acceptableFlags
        flagDetector = (\arg counter -> if arg `elem` acceptableFlags then counter + 1 else counter)

-- Find and return a flag from arguments
getFlag :: [String] -> String
getFlag args = foldr (\arg acc -> if arg `elem` ["-i", "-1", "-2", "-h"] then arg else acc) "" args

-- Find and return file a path from arguments
getFilePath :: [String] -> String
getFilePath args = foldr (\arg acc -> if not $ arg `elem` ["-i", "-1", "-2", "-h"] then arg else acc) "" args

 -- Get content of requested file (from file path argument or stdin) as a string wrapped in IO
readInput :: [String] -> IO String
readInput args
    -- If empty string is parsed from args as file path -> read from stdin, otherwise read from provided file
    | fileName == "" = do getContents
    | otherwise = do 
                    fileExists <- doesFileExist $ fileName
                    if fileExists -- If file exists on provided path, read CFG from it. Trow error otherwise
                        then readFile $ fileName
                        else error "Error!\n\tProvided file path does not exist!"
        where
            fileName = getFilePath args
                