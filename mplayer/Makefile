all: MPlayer-1.1.1
	cd MPlayer-1.1.1; $(MAKE) $(MFLAGS)

MPlayer-1.1.1:
	echo "Run './get-mplayer' to get the mplayer source code."

install: all
	cp ./MPlayer-1.1.1/mplayer ../MPlayerScreenSaverX/

clean:
	cd MPlayer-1.1.1; $(MAKE) clean $(MFLAGS)
