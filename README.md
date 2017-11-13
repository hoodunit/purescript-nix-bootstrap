## Example project: PureScript development with Nix

The idea here is to be able to develop PureScript applications without installing global dependencies and with highly reproducible build, development, and deployment environments. The only global dependency should be the Nix package manager. This setup lets you build the app with specified system dependencies, drop into a shell for development with those dependencies installed, and build a Docker image with only your app, the exact dependencies it uses, and any other system dependencies you wish to include for debugging. Pinning system package versions with Nix should allow us to come back to the same project much later and easily reproduce the same environments, or switch seamlessly between different projects using different versions of dependencies.

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

2) Install PureScript + NodeJS + any other system dependencies, then drop into a shell with those installed:

```
nix-shell
```

3) Install project dependencies (PureScript and NPM packages):

```
npm install
./bower update --force-latest
```

4) Build project, rebuilding on file changes:

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
nix-prefetch-git https://github.com/nixos/nixpkgs-channels --rev cfafd6f5a819472911eaf2650b50a62f0c143e3e > nixpkgs.json
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
