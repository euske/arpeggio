# Makefile for assets

PYTHON=python
LAME=lame

.SUFFIXES: .png .wav .mp3

.wav.mp3:
	$(LAME) $< $@

ASSETS=correct.mp3 next.mp3 wrong1.mp3 wrong2.mp3 wrong3.mp3 bang.mp3

all: $(ASSETS)

clean:
	-$(RM) $(ASSETS)

correct.mp3: correct.wav
next.mp3: next.wav
wrong1.mp3: wrong1.wav
wrong2.mp3: wrong2.wav
wrong3.mp3: wrong3.wav
bang.mp3: bang.wav
