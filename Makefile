OUTPUT := flp21-fun
ZIP := flp-fun-xglosm01.zip

$(OUTPUT):
	ghc --make -Wall -o $@ Main.hs

pack: $(ZIP)

$(ZIP): Makefile tests/grammars/test* tests/test.py README.md *.hs
	zip -r $@ $^

clear: clear_output clear_hi clear_o

clear_output: 
	rm -f $(OUTPUT)

clear_hi:
	rm -f *.hi

clear_o:
	rm -f *.o

test:
	python3 tests/test.py

testV:
	python3 tests/test.py -v

testVD:
	python3 tests/test.py -v --debug