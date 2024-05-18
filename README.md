# whisperfile

This is a fork of [llamafile](https://github.com/Mozilla-Ocho/llamafile) which builds llamafiles for [whisper.cpp](https://github.com/ggerganov/whisper.cpp). A huge credit and thanks to the original authors of these wonderful projects.

Much of this README will be a copy from the original project, with some modifications to reflect the changes made in this fork.

NOTE: Currently this project only supports the `server` binary of whisper.cpp. In the future there may be support for the other binaries as well, or a wrapper binary similar to the original `llamafile` project to support both cli and server implementations.

## Quickstart

You can find prebuilt whisperfiles here: https://huggingface.co/cjpais/whisperfile

To run the whisperfile, download it and run it like so:

```sh
chmod +x whisper.base.llamafile
./whisper.base.llamafile
```

This will start a whisper.cpp server at port 51524. You can access the server by visiting `http://localhost:51524` in your browser. It is set up to automatically convert audio files into the correct format with the `--convert` flag. This requires ffmpeg to be installed on the host system. The API endpoint is the same as the original whisper.cpp server. You can find the documentation for it at [here](whisper.cpp/server)

## How llamafile works

A llamafile is an executable LLM that you can run on your own
computer. It contains the weights for a given open LLM, as well
as everything needed to actually run that model on your computer.
There's nothing to install or configure (with a few caveats, discussed
in subsequent sections of this document).

This is all accomplished by combining llama.cpp with Cosmopolitan Libc,
which provides some useful capabilities:

1. llamafiles can run on multiple CPU microarchitectures. We
   added runtime dispatching to llama.cpp that lets new Intel systems use
   modern CPU features without trading away support for older computers.

2. llamafiles can run on multiple CPU architectures. We do
   that by concatenating AMD64 and ARM64 builds with a shell script that
   launches the appropriate one. Our file format is compatible with WIN32
   and most UNIX shells. It's also able to be easily converted (by either
   you or your users) to the platform-native format, whenever required.

3. llamafiles can run on six OSes (macOS, Windows, Linux,
   FreeBSD, OpenBSD, and NetBSD). If you make your own llama files, you'll
   only need to build your code once, using a Linux-style toolchain. The
   GCC-based compiler we provide is itself an Actually Portable Executable,
   so you can build your software for all six OSes from the comfort of
   whichever one you prefer most for development.

4. The weights for an LLM can be embedded within the llamafile.
   We added support for PKZIP to the GGML library. This lets uncompressed
   weights be mapped directly into memory, similar to a self-extracting
   archive. It enables quantized weights distributed online to be prefixed
   with a compatible version of the llama.cpp software, thereby ensuring
   its originally observed behaviors can be reproduced indefinitely.

5. Finally, with the tools included in this project you can create your
   _own_ llamafiles, using any compatible model weights you want. You can
   then distribute these llamafiles to other people, who can easily make
   use of them regardless of what kind of computer they have.

## Gotchas

On macOS with Apple Silicon you need to have Xcode Command Line Tools
installed for llamafile to be able to bootstrap itself.

If you use zsh and have trouble running llamafile, try saying `sh -c
./llamafile`. This is due to a bug that was fixed in zsh 5.9+. The same
is the case for Python `subprocess`, old versions of Fish, etc.

On some Linux systems, you might get errors relating to `run-detectors`
or WINE. This is due to `binfmt_misc` registrations. You can fix that by
adding an additional registration for the APE file format llamafile
uses:

```sh
sudo wget -O /usr/bin/ape https://cosmo.zip/pub/cosmos/bin/ape-$(uname -m).elf
sudo chmod +x /usr/bin/ape
sudo sh -c "echo ':APE:M::MZqFpD::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
sudo sh -c "echo ':APE-jart:M::jartsr::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
```

As mentioned above, on Windows you may need to rename your llamafile by
adding `.exe` to the filename.

Also as mentioned above, Windows also has a maximum file size limit of 4GB
for executables. The LLaVA server executable above is just 30MB shy of
that limit, so it'll work on Windows, but with larger models like
WizardCoder 13B, you need to store the weights in a separate file. An
example is provided above; see "Using llamafile with external weights."

On WSL, it's recommended that the WIN32 interop feature be disabled:

```sh
sudo sh -c "echo -1 > /proc/sys/fs/binfmt_misc/WSLInterop"
```

In the instance of getting a `Permission Denied` on disabling interop through CLI, it can be permanently disabled by adding the following in `/etc/wsl.conf`

```sh
[interop]
enabled=false
```

On Raspberry Pi, if you get "mmap error 12" then it means your kernel is
configured with fewer than 48 bits of address space. You need to upgrade
to RPI 5. You can still use RPI 4 if you either (1) rebuild your kernel,
or (2) get your SDcard OS image directly from Ubuntu (don't use RPI OS).

On any platform, if your llamafile process is immediately killed, check
if you have CrowdStrike and then ask to be whitelisted.

## Supported OSes

llamafile supports the following operating systems, which require a minimum
stock install:

- Linux 2.6.18+ (i.e. every distro since RHEL5 c. 2007)
- Darwin (macOS) 23.1.0+ [1] (GPU is only supported on ARM64)
- Windows 8+ (AMD64 only)
- FreeBSD 13+
- NetBSD 9.2+ (AMD64 only)
- OpenBSD 7+ (AMD64 only)

On Windows, llamafile runs as a native portable executable. On UNIX
systems, llamafile extracts a small loader program named `ape` to
`$TMPDIR/.llamafile` or `~/.ape-1.9` which is used to map your model
into memory.

[1] Darwin kernel versions 15.6+ _should_ be supported, but we currently
have no way of testing that.

## Supported CPUs

llamafile supports the following CPUs:

- **AMD64** microprocessors must have AVX. Otherwise llamafile will
  print an error and refuse to run. This means that if you have an Intel
  CPU, it needs to be Intel Sandybridge or newer (circa 2011+), and if
  you have an AMD CPU, then it needs to be Bulldozer or newer (circa
  2011+). Support for AVX512, AVX2, FMA, F16C, and VNNI are
  conditionally enabled at runtime if you have a newer CPU.

- **ARM64** microprocessors must have ARMv8a+. This means everything
  from Apple Silicon to 64-bit Raspberry Pis will work, provided your
  weights fit into memory.

## GPU support

llamafile supports the following kinds of GPUs:

- Apple Metal
- NVIDIA
- AMD

GPU on MacOS ARM64 is supported by compiling a small module using the
Xcode Command Line Tools, which need to be installed. This is a one time
cost that happens the first time you run your llamafile. The DSO built
by llamafile is stored in `$TMPDIR/.llamafile` or `$HOME/.llamafile`.
Offloading to GPU is enabled by default when a Metal GPU is present.
This can be disabled by passing `-ngl 0` or `--gpu disable` to force
llamafile to perform CPU inference.

Owners of NVIDIA and AMD graphics cards need to pass the `-ngl 999` flag
to enable maximum offloading. If multiple GPUs are present then the work
will be divided evenly among them by default, so you can load larger
models. Multiple GPU support may be broken on AMD Radeon systems. If
that happens to you, then use `export HIP_VISIBLE_DEVICES=0` which
forces llamafile to only use the first GPU.

Windows users are encouraged to use our release binaries, because they
contain prebuilt DLLs for both NVIDIA and AMD graphics cards, which only
depend on the graphics driver being installed. If llamafile detects that
NVIDIA's CUDA SDK or AMD's ROCm HIP SDK are installed, then llamafile
will try to build a faster DLL that uses cuBLAS or rocBLAS. In order for
llamafile to successfully build a cuBLAS module, it needs to be run on
the x64 MSVC command prompt. You can use CUDA via WSL by enabling
[Nvidia CUDA on
WSL](https://learn.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl)
and running your llamafiles inside of WSL. Using WSL has the added
benefit of letting you run llamafiles greater than 4GB on Windows.

On Linux, NVIDIA users will need to install the CUDA SDK (ideally using
the shell script installer) and ROCm users need to install the HIP SDK.
They're detected by looking to see if `nvcc` or `hipcc` are on the PATH.

If you have both an AMD GPU _and_ an NVIDIA GPU in your machine, then
you may need to qualify which one you want used, by passing either
`--gpu amd` or `--gpu nvidia`.

In the event that GPU support couldn't be compiled and dynamically
linked on the fly for any reason, llamafile will fall back to CPU
inference.

## Source installation

Developing on llamafile requires a modern version of the GNU `make`
command (called `gmake` on some systems), `sha256sum` (otherwise `cc`
will be used to build it), `wget` (or `curl`), and `unzip` available at
[https://cosmo.zip/pub/cosmos/bin/](https://cosmo.zip/pub/cosmos/bin/).
Windows users need [cosmos bash](https://justine.lol/cosmo3/) shell too.

```sh
make -j8
sudo make install PREFIX=/usr/local
```

## Creating whisperfiles

If you want to be able to just say:

```sh
./whisper-tiny.llamafile
```

...and have it run the web server without having to specify arguments,
then you can embed both the weights and a special `.args` inside, which
specifies the default arguments. First, let's create a file named
`.args` which has this content:

```sh
-m
tiny.bin
--host
0.0.0.0
--port
51524
--convert
-pc
-pr
...
```

As we can see above, there's one argument per line. The `...` argument
optionally specifies where any additional CLI arguments passed by the
user are to be inserted. Next, we'll add both the weights and the
argument file to the executable:

```sh
cp /usr/local/bin/whisperfile whisper-tiny.llamafile

zipalign -j0 \
  whisper-tiny.llamafile \
  tiny.bin \
  .args

./llava.llamafile
```

Congratulations. You've just made your own LLM executable that's easy to
share with your friends.

## Distribution

One good way to share a llamafile with your friends is by posting it on
Hugging Face. If you do that, then it's recommended that you mention in
your Hugging Face commit message what git revision or released version
of llamafile you used when building your llamafile. That way everyone
online will be able verify the provenance of its executable content. If
you've made changes to the llama.cpp or cosmopolitan source code, then
the Apache 2.0 license requires you to explain what changed. One way you
can do that is by embedding a notice in your llamafile using `zipalign`
that describes the changes, and mention it in your Hugging Face commit.

## Documentation

There's a manual page for each of the llamafile programs installed when you
run `sudo make install`. The command manuals are also typeset as PDF
files that you can download from our GitHub releases page. Lastly, most
commands will display that information when passing the `--help` flag.

## Technical details

Here is a succinct overview of the tricks we used to create the fattest
executable format ever. The long story short is llamafile is a shell
script that launches itself and runs inference on embedded weights in
milliseconds without needing to be copied or installed. What makes that
possible is mmap(). Both the llama.cpp executable and the weights are
concatenated onto the shell script. A tiny loader program is then
extracted by the shell script, which maps the executable into memory.
The llama.cpp executable then opens the shell script again as a file,
and calls mmap() again to pull the weights into memory and make them
directly accessible to both the CPU and GPU.

### ZIP weights embedding

The trick to embedding weights inside llama.cpp executables is to ensure
the local file is aligned on a page size boundary. That way, assuming
the zip file is uncompressed, once it's mmap()'d into memory we can pass
pointers directly to GPUs like Apple Metal, which require that data be
page size aligned. Since no existing ZIP archiving tool has an alignment
flag, we had to write about [500 lines of code](llamafile/zipalign.c) to
insert the ZIP files ourselves. However, once there, every existing ZIP
program should be able to read them, provided they support ZIP64. This
makes the weights much more easily accessible than they otherwise would
have been, had we invented our own file format for concatenated files.

### Microarchitectural portability

On Intel and AMD microprocessors, llama.cpp spends most of its time in
the matmul quants, which are usually written thrice for SSSE3, AVX, and
AVX2. llamafile pulls each of these functions out into a separate file
that can be `#include`ed multiple times, with varying
`__attribute__((__target__("arch")))` function attributes. Then, a
wrapper function is added which uses Cosmopolitan's `X86_HAVE(FOO)`
feature to runtime dispatch to the appropriate implementation.

### Architecture portability

llamafile solves architecture portability by building llama.cpp twice:
once for AMD64 and again for ARM64. It then wraps them with a shell
script which has an MZ prefix. On Windows, it'll run as a native binary.
On Linux, it'll extract a small 8kb executable called [APE
Loader](https://github.com/jart/cosmopolitan/blob/master/ape/loader.c)
to `${TMPDIR:-${HOME:-.}}/.ape` that'll map the binary portions of the
shell script into memory. It's possible to avoid this process by running
the
[`assimilate`](https://github.com/jart/cosmopolitan/blob/master/tool/build/assimilate.c)
program that comes included with the `cosmocc` compiler. What the
`assimilate` program does is turn the shell script executable into
the host platform's native executable format. This guarantees a fallback
path exists for traditional release processes when it's needed.

### GPU support

Cosmopolitan Libc uses static linking, since that's the only way to get
the same executable to run on six OSes. This presents a challenge for
llama.cpp, because it's not possible to statically link GPU support. The
way we solve that is by checking if a compiler is installed on the host
system. For Apple, that would be Xcode, and for other platforms, that
would be `nvcc`. llama.cpp has a single file implementation of each GPU
module, named `ggml-metal.m` (Objective C) and `ggml-cuda.cu` (Nvidia
C). llamafile embeds those source files within the zip archive and asks
the platform compiler to build them at runtime, targeting the native GPU
microarchitecture. If it works, then it's linked with platform C library
dlopen() implementation. See [llamafile/cuda.c](llamafile/cuda.c) and
[llamafile/metal.c](llamafile/metal.c).

In order to use the platform-specific dlopen() function, we need to ask
the platform-specific compiler to build a small executable that exposes
these interfaces. On ELF platforms, Cosmopolitan Libc maps this helper
executable into memory along with the platform's ELF interpreter. The
platform C library then takes care of linking all the GPU libraries, and
then runs the helper program which longjmp()'s back into Cosmopolitan.
The executable program is now in a weird hybrid state where two separate
C libraries exist which have different ABIs. For example, thread local
storage works differently on each operating system, and programs will
crash if the TLS register doesn't point to the appropriate memory. The
way Cosmopolitan Libc solves that on AMD is by using SSE to recompile
the executable at runtime to change `%fs` register accesses into `%gs`
which takes a millisecond. On ARM, Cosmo uses the `x28` register for TLS
which can be made safe by passing the `-ffixed-x28` flag when compiling
GPU modules. Lastly, llamafile uses the `__ms_abi__` attribute so that
function pointers passed between the application and GPU modules conform
to the Windows calling convention. Amazingly enough, every compiler we
tested, including nvcc on Linux and even Objective-C on MacOS, all
support compiling WIN32 style functions, thus ensuring your llamafile
will be able to talk to Windows drivers, when it's run on Windows,
without needing to be recompiled as a separate file for Windows. See
[cosmopolitan/dlopen.c](https://github.com/jart/cosmopolitan/blob/master/libc/dlopen/dlopen.c)
for further details.

## Security

TODO: Currently security with pledge is not implemented for whisperfile.

WARNING: Given this you may consider the security to be quite poor.

<!-- llamafile adds pledge() and SECCOMP sandboxing to llama.cpp. This is
enabled by default. It can be turned off by passing the `--unsecure`
flag. Sandboxing is currently only supported on Linux and OpenBSD on
systems without GPUs; on other platforms it'll simply log a warning.

Our approach to security has these benefits:

1. After it starts up, your HTTP server isn't able to access the
   filesystem at all. This is good, since it means if someone discovers
   a bug in the llama.cpp server, then it's much less likely they'll be
   able to access sensitive information on your machine or make changes
   to its configuration. On Linux, we're able to sandbox things even
   further; the only networking related system call the HTTP server will
   allowed to use after starting up, is accept(). That further limits an
   attacker's ability to exfiltrate information, in the event that your
   HTTP server is compromised.

2. The main CLI command won't be able to access the network at all. This
   is enforced by the operating system kernel. It also won't be able to
   write to the file system. This keeps your computer safe in the event
   that a bug is ever discovered in the GGUF file format that lets
   an attacker craft malicious weights files and post them online. The
   only exception to this rule is if you pass the `--prompt-cache` flag
   without also specifying `--prompt-cache-ro`. In that case, security
   currently needs to be weakened to allow `cpath` and `wpath` access,
   but network access will remain forbidden.

Therefore your llamafile is able to protect itself against the outside
world, but that doesn't mean you're protected from llamafile. Sandboxing
is self-imposed. If you obtained your llamafile from an untrusted source
then its author could have simply modified it to not do that. In that
case, you can run the untrusted llamafile inside another sandbox, such
as a virtual machine, to make sure it behaves how you expect. -->

## Licensing

The whisperfile project is Apache 2.0-licensed.
While the llamafile project is Apache 2.0-licensed, our changes
to llama.cpp are licensed under MIT (just like the llama.cpp project
itself) so as to remain compatible and upstreamable in the future,
should that be desired.
