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
import os
import sys

# Absolute path of this file, test could be called from wherever
ROOT_DIR = "/".join(os.path.abspath(__file__).split("/")[:-2])

# Number of tests, if you wish to make some tests yourself, stick with naming convention and increment this counter by the number of new tests
TESTS = 10

class Grammar:
    '''
    Just a little class to hold grammars and provide a method for it's parsing from input
    and a handy tool for comparing them, ignoring the order of rules, nonterminals and terminals
    and subtracting them to get the difference between 2 grammars for better debugging of flp21-fun program
    '''
    def __init__(self, init_input):
        '''Init grammar object, if not enough lines loaded, assume the conversion failed'''
        lines = len(init_input)
        if lines < 4:
            self.failed = True
        else:
            self.failed = False
        # Set properties if present
        self.nonterminals = sorted(list(set(init_input[0].strip().split(',')) if lines > 0 else []))
        self.terminals = sorted(list(set(init_input[1].strip().split(',')) if lines > 1 else []))
        self.starting_symbol = init_input[2].strip() if lines > 2 else ""
        # Filter out empty lines just in case there is an empty line at the end of output or something ...
        self.rules = sorted(list(set([line.strip() for line in init_input[3:] if line]) if lines > 3 else []))

    def __eq__(self, other):
        '''Method for camparing two grammars. Assume the other object is also of Grammar class'''
        # If each of loaded objects failed, fail
        if self.failed or other.failed:
            return False
        # Else - compare all set's of both parameters
        return self.nonterminals == other.nonterminals and self.terminals == other.terminals and \
               self.starting_symbol == other.starting_symbol and self.rules == other.rules

    def __repr__(self):
        '''Define grammars representation as string'''
        return "" if self.failed else '\n'.join([','.join(self.nonterminals), ','.join(self.terminals), self.starting_symbol, '\n'.join(self.rules)])
    
    def __sub__(self, other):
        '''Get difference between two grammars'''
        if self.failed:
            return ""
        if other.failed:
            return str(other)
        return '\n'.join([
            "Terminals:\t" + ','.join([n for n in self.nonterminals if n not in other.nonterminals]),
            "Nonterminals:\t" + ','.join([t for t in self.terminals if t not in other.terminals]),
            "Rules:\t\t" + '|'.join([r for r in self.rules if r not in other.rules])])

def print_verbose_res(grammars, form):
    '''Print somehow nicely the result and reference grammars'''
    correct = grammars[0] == grammars[1]
    print(form + ": " + (success("Success") if correct else error("Failed")))
    if "--debug" in sys.argv:
        print("\n"+test_c("Groud truth grammar:"))
        print(grammars[0])
        print("\n"+test_c("Output grammar:"))
        print(grammars[1], end="\n\n")
    # Print the differences
    if not correct:
        print("\nFound mistakes\n")
        print("\nWhat is parsed grammar missing:\n" + error(grammars[0] - grammars[1]))
        print("\nWhat is redundant in parsed grammar:\n" + error(grammars[1] - grammars[0]))

    if form.startswith("Chom"):
        print("\n")

def abs_p(path):
    return ROOT_DIR + "/" + path

# Define some colored strings
def error(string):
    return '\033[91m' + string + '\033[0m'

def success(string):
    return '\033[92m' + string + '\033[0m'

def test_c(string):
    return '\033[93m' + string + '\033[0m'

def big(string):
    return '\033[94m' + string + '\033[0m'


def print_form_success(results, form, tabs=1):
    '''Print summary of one of three tasks (Internal representation of CFG, Non-trivial CFG, CNF CFG)'''
    percentage = sum(results)/len(results)*100
    output = f"{percentage} % ({sum(results)} of {len(results)}) correct"
    print(form + ": " + tabs*'\t' + (success(output) if percentage == 100 else error(output)))

if __name__ == "__main__":
    # First, cehck the CLI args -> if some integers present, execute only tests specified by those integers
    specific_tests = sorted([int(num) for num in sys.argv if num.isnumeric() and int(num) > 0 and int(num) <= TESTS])
    if not specific_tests:
        # If none tests specified on CLI, run all of them
        specific_tests = range(1,TESTS+1)
    tests = [(abs_p(f'tests/grammars/test{num}'), num) for num in specific_tests]

    # Now, all test directories should have 3 files - cfgIn (raw grammar - internal representation), cfgNT (non-trivial) and cfgCNF (Chomsky's normal form)
    # Do not check it, let's assume it exists like that ...
    # Define some "constants" to ease our way...
    g_types = [('cfgIn', '-i'),('cfgNT', '-1'),('cfgCNF', '-2')] # CFG as text in file in one of required form and it's corresponding flag for flp21-fun
    results = []        # Here will be stored the results

    # Execute the parser on all required tests
    for test in tests:
        # For each test - perform each operation
        for g_type in g_types:
            with open(f'{test[0]}/{g_type[0]}') as f:
                g_input = f.readlines()
            # Get the reference grammar
            gt_grammar = Grammar(g_input)
            # Execute our parser and pass it's output into our Grammar class
            out_grammar = Grammar(os.popen(f'{abs_p("flp21-fun")} {g_type[1]} {test[0]}/cfgIn').readlines())
            # Store the results
            results.append((gt_grammar, out_grammar, test[1]))
    
    # Evaluate the results for each test and all it's formats
    for i in range(0, len(results), 3):
        res = [g[0]==g[1] for g in results[i:i+3]]
        # percentage
        p = str(sum(res)/3*100)
        res_string = f"\t{p[:min(len(p),5)]} % - " + ("Passed" if all(res) else "Failed")
        print(big(f"test #{results[i][2]}:") + (success(res_string) if all(res) else error(res_string))+'\n')
        if '-v' in sys.argv:
            print_verbose_res(results[i], "Internal representation")
            print_verbose_res(results[i+1], "Non-trivial form")
            print_verbose_res(results[i+2], "Chomsky's normal from")
        
    # Summary
    res = [g[0]==g[1] for g in results]
    p = sum(res)/len(res)*100
    print(big("Summary:"))
    print(f'\tGrammar checks: \t{len(results)}')
    print(f'\tCorrect: \t\t{sum(res)}')
    print('\tSuccess rate: \t\t' + (success(f'{p} %') if p == 100 else error(f'{p} %')))
    print_form_success(res[::3], "\nInternal representation")
    print_form_success(res[1::3], "Non-trivial form", 2)
    print_form_success(res[2::3], "Chomsky's normal from", 2)
