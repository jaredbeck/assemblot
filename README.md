# Assembly Robots (assemblot)

Program battling robots using a tiny subset of x86 assembly.

You can purchase a gun, shields, engine, and CPU clock speed for your robot. If
you write efficient assembly, you can run a lower clock speed and have more
points to spend on armament!

Supported CPU instructions and registers are described in `rules.yml`, where you
can also configure the size of the arena and stuff like shield fade rate and
walls-are-lava.

## Usage

```bash
# Basic bot vs. itself
ruby -I lib lib/assemblot/server.rb rules.yml bots/basic.yml bots/basic.yml &
open frontend/app/index.html
```

## Getting started

- Learn to accelerate with the `acl` instruction (eg. `bots/basic.yml`)
- Learn to rotate the gun turret and fire

## Goal is fun, not perfect emulation

If I've misunderstood something fundamental about x86 CPUs (which is likely) PRs
are welcome, but the goal is just to have some fun, not to build a well-featured
x86 emulator.

## Implemented so far ..

- Arena
- Bot movement (`acl`)
- Walls
- A dozen CPU instructions
- Bot attribute: CPU clock speed
- Basic GUI (Eventmachine / WebSocket / HTML Canvas)

## TODO

- GUI inputs: start, pause, stop, add/remove bots
- [fix canvas flicker](https://gamedev.stackexchange.com/questions/182955/my-html-canvas-keep-flickering)
- new file format so that line numbers match up
- randomize initial bot placement
- rotate gun turret and fire
- bot health
- walls are lava
- bot attribute points (buying power-ups)
- purchase more CPU registers (expensive!)
- frame rate limit

## References

- [x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)
- Instructions
  - [x86 and amd64 instruction reference](https://www.felixcloutier.com/x86/)
  - [Intel x86 JUMP quick reference](http://unixwiz.net/techtips/x86-jumps.html)
- Flags
  - [FLAGS](https://en.wikipedia.org/wiki/FLAGS_register)
  - [PF](https://en.wikipedia.org/wiki/Parity_flag)
  - [ZF](https://en.wikipedia.org/wiki/Zero_flag)
