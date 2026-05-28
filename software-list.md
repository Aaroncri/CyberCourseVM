# Software List

This is the working list of software for the Ubuntu student workstation.

The setup can be factored into multiple scripts, but `install.sh` should remain
the master entry point that installs everything.

## Core Development

- git
- curl
- wget
- vim
- nano
- tmux
- tree
- jq
- build-essential
- make
- pkg-config
- libssl-dev
- clang
- cmake
- file
- xxd
- hexdump
- python3
- python3-pip
- python3-venv
- pipx
- openssh-client
- openssh-server

## Networking

- iproute2
- net-tools
- dnsutils
- traceroute
- tcpdump
- tshark
- wireshark
- nmap
- netcat-openbsd
- socat
- whois

## Cryptography

- openssl
- john
- hashcat

## Rust and Lean Development

- rustup
- rustc
- cargo
- rustfmt
- clippy
- elan
- lean
- lake

## LaTeX

- texlive-latex-base
- texlive-latex-recommended
- texlive-latex-extra
- texlive-fonts-recommended
- latexmk

## Desktop Apps

- Obsidian
- Visual Studio Code

## Web and Server Tools

- nginx
- docker.io
- docker-compose-v2
- OWASP ZAP
- Burp Suite Community

The default setup installs both ZAP and Burp Suite Community. Set
`COURSE_WEB_PROXY_TOOL=zap`, `burp`, or `none` to narrow that during prototype
builds.

## Cloud and Infrastructure

- Terraform
- AWS CLI

Cloud credentials must be configured by students during the relevant module and
must not be built into the VM image.
