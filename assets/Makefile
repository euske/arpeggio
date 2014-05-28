# Makefile for assets

PYTHON=python
LAME=lame

.SUFFIXES: .png .wav .mp3

.wav.mp3:
	$(LAME) $< $@

ASSETS=correct.mp3 wrong.mp3 next.mp3

all: $(ASSETS)

clean:
	-$(RM) $(ASSETS)

correct.mp3: correct.wav
wrong.mp3: wrong.wav
next.mp3: next.wav
