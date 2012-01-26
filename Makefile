HFLAGS= #-I/path/to/lib/include -L/path/to/lib

_dummy_target: Watcher.o Watcher.h
	ghc $(HFLAGS) --make Main -o a.out Watcher.o -framework CoreServices -framework Foundation
