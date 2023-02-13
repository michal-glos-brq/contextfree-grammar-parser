```
                                    #####################################
                                    #@$%&            2022           &%$@#
                                    #!     FLP - Projekt BKG-2-CNF     !#
                                    #!           Michal Glos           !#
                                    #!            xglosm01             !#
                                    #!              __                 !#
                                    #!            <(o )___             !#
                                    #!             ( ._> /             !#
                                    #!              `---'              !#
                                    #@$%&                           &%$@#
                                    #####################################
```
# Functional project - Functional and logical programming 2021/2022
### Author: xglosm01
## Introduction
I worked on assignment `BKG-2-CNF`. This `README.md` does not contain any comments regarding the implementation of this assignment. All necessary comments are provided directly in the source code, where i tried to stick with advice of keeping those comments brief. Although there are some areas, where i tried to describe the functionality and purpose of code more extensively because it could sometimes get a little bit confusing and complex.
As was mentioned on exercises, I tried to focus more on the functionality of code rather than catching all possible exceptions. Of course, there is some functionality to handle different inputs but the main purpose is to execute the context-free grammar parsing well, when called and provided with grammar correctly.
The directory structure of the submitted zipfile is as follows:
 - `CFG.hs`                -  context-free grammar datatype and it's parsing to and from string
 - `CFGcnf.hs`             - parsing context-free grammar with no trivial rules into context-free grammar in Chomsky's normal form
 - `CFGnonTrivial.hs`      - parsing context-free grammar with no epsilon rules into context-free grammar without trivial rules
 - `Main.hs`               - main module controlling the parsing process into required format
 - `Makefile`              - compiling, clearing after compilation and packing assignment into zipfile
 - `README.md`             - this file
 - `tests`                 - contains test data and testing python script
   - `grammars`            - contains test data, structure of one test shown below
     - `test1`             - test #1
       - `cfgCNF`          - text representation of context-free grammar in Chomsky's normal form
       - `cfgIn`           - text representation of context-free grammar without epsilon rules
       - `cfgNT`           - text representation of context-free grammar without trivial rules
   - `test.py`             - python script for running tests 

## Testing
There are in total 10 grammars to be used for testing this solution. Each grammar is present in all three forms (`cfgCNF` - Chomsky's normal form, `cfgIn` - raw form, `cfgNT` - grammar without trivial rules). This number could be extended even further, just stick with the naming convention written above. You would create a new folder `tests/grammars/test11` (always increment this number by one), all your grammars should respect the file naming convention mentioned above also. The last thing to do, in order to run your very own tests is to increment the variable in `tests/test.py` on line 23 (`TESTS = 10`) by the number of tests you added yourself.
When running the tests, you get success rate for each grammar and for each task  (-i, -1, -2) and total success rate. When the tests are run with `-v` flag, you get result for every combination of grammar and task. Also when the parsing is not correct, the script writes out the difference between parsed and ground-truth grammars. The last option which could be used is `--debug` option, which has to be used in combination with `-v` option. This option makes the script print out each ground-truth and parsed grammar under the result of each task.
#### Examples
 - `python3 tests/test.py` or `python3 test.py` just runs the tests (could be run from whichever directory)
 - `python3 tests/test.py 2` will run the test number 2
 - `python3 tests/test.py 2 5 3 4` will run the tests number 2,3,4,5
 - `python3 tests/test.py -v` will print separately result of every task for all grammars
 - `python3 tests/test.py -v --debug` will also print each ground-truth and parsed grammar
 - `python3 tests/test.py 2  3 -v 4 5 --debug` combination of all above, the order of arguments is irrelevant

#### Makefile
 - `make` - builds the solution
 - `make clear` - clears the working directory from files generated during `make`
 - `make pack` - packs the solution into zipfile
 - `make test` - runs `python3 tests/test.py`
 - `make testV` - runs `python3 tests/test.py -v`
 - `make testVD` - runs `python3 tests/test.py -v --debug`
