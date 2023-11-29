# Porklike

This is an NES port of the [Lazy Dev's Rogulike Pico-8 tutorials](https://www.youtube.com/playlist?list=PLea8cjCua_P3LL7J1Q9b6PJua0A-96uUS)

## Build
### Dependencies
* [CA65 toolchain](https://cc65.github.io/doc/ca65.html)
* [Python 3](https://www.python.org/downloads/)
* [FCEUX](https://fceux.com/web/home.html)

Once you have the dependencies installed, you can build and run it:
```sh
$ make && make run
```

## About
I really like [Pico-8](https://www.lexaloffle.com/pico-8.php), and one of the best tutorial series for it is  the Roguelike (or "Porklike") tutorials by Lazy Devs Academy.

I also really like NES development, most of which I learned from the [Pikuma NES development course](https://pikuma.com/courses/nes-game-programming-tutorial) - in fact, most of the boilerplate code is from there!

So I thought - why not try to port the Porklike to NES? Of course, this should be taken as a professional "port" or anything silly like that, it's merely an exercise and a fun way to learn NES development.

The `fceux_symbols.py` script which translates CA65 debug symbols for FCEUX was taken from [Brad Smith's example project](https://github.com/bbbradsmith/NES-ca65-example/).