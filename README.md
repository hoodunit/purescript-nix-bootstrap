## Example project: PureScript development with Nix

Goals: develop PureScript applications with highly reproducible build, development, and deployment environments and without installing global dependencies. The only global dependency needed should be the [Nix package manager](https://nixos.org/nix/).

This setup lets you build a PureScript app with specified system dependencies, drop into a shell for development with those dependencies installed, and build a Docker image with only your app and the exact dependencies it uses. Pinned system dependency versions mean you can come back to the same project later and easily reproduce the same environments, or switch seamlessly between different projects using different versions of dependencies.

Note that this example does /not/ use Nix to install PureScript or PureScript library dependencies themselves, but only system dependencies needed by the project i.e. NodeJS. PureScript itself is installed from npm and relies on npm's `package-lock.json` to be reproducible.

### Building: one-liner

With Nix installed, the following command will install system dependencies (NodeJS), install project dependencies (NPM and PureScript packages), and build the app:

```
nix-build
```

To run it:

```
./result/bin/purescript-nix-bootstrap
```

### Building: development

1) Install Nix from [here](https://nixos.org/nix/).

    The only dependency you install globally on your system is the Nix package manager. Everything else is installed in a temporary sandbox by Nix as needed. Make sure the Nix binaries are on your path, e.g. by adding `~/.nix-profile/bin` to your path.

2) Install NodeJS + any other system dependencies, then drop into a shell with those installed:

```
nix-shell
```

3) Install project dependencies (PureScript and NPM packages):

```
npm install
./bower update --force-latest
```

4) Build project, with fast rebuilds on file changes:

```
npm run build:watch
```

### Running in Docker

Build Docker image to `./result`:

```
nix-build docker.nix
```

Load image into Docker locally:

```
docker load -i result
```

Run image:

```
docker run -it --rm --name purescript-nix-bootstrap purescript-nix-bootstrap
```

### Modifying system dependencies

Add or remove system dependencies in `buildInputs` of the file `default.nix`. The dependencies will be be available in build, development, and Docker environments.

### Modifying Docker system dependencies

Add or remove system dependencies in `contents` of the file `docker.nix`. These are extra dependencies defined for Docker images only.

### Updating all system dependencies

System dependencies are specified using Nix in `default.nix`. The versions of those dependencies installed are determined by the version of pinned Nix package set specified in `nixpkgs.json`. Specifically, `nixpkgs.json` contains a Git repository commit hash and an SHA256 hash of the contents of the repository for verification. The repository specifies the versions of dependencies that are being used by default. They can also be overridden as needed.

To update the pinned version, find the hash of the commit you want from the nixpkgs-channels repository (https://github.com/nixos/nixpkgs-channels), then dump it to `nixpkgs.json` with the following command (substituting the hash for the one you want):

```
nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/nixos/nixpkgs-channels --rev 7db611f2af869bac6e31ba814a5593c52d54ec19 > nixpkgs.json'
```

Commit the result.

### Editor support

This setup works with Emacs' [purescript-mode](https://github.com/dysinger/purescript-mode) if you set the following option:

```
(setq psc-ide-use-npm-bin t)
```

No need to install PureScript globally. It will use the version in your project directory.

### Caveats

You can build Docker images without Docker, but Docker still needs to be installed separately to run them. In theory you should be able to install Docker with Nix as well, but at the time of last testing I did not have luck with this.
