# Fields Information Security Student Environment

This repository is a simple starting point for building the Ubuntu student
workstation used by the Fields Information Security Program.

The goal is to keep the source of truth small and easy to audit:

- `software-list.md`: the software we intend to install.
- `install.sh`: the master setup script.
- `verify.sh`: checks that the expected tools are available.
- `packages/`: optional helper scripts used by `install.sh`.
- `tests/expected-tools.txt`: command names checked by `verify.sh`.

## Provision A Clean VM

From a clean Ubuntu Desktop VM:

```bash
sudo ./install.sh
```

The setup may be factored into multiple scripts, but students and instructors
should only need to run `install.sh`.

To install Burp Suite Community instead of OWASP ZAP:

```bash
sudo COURSE_WEB_PROXY_TOOL=burp ./install.sh
```

To skip web proxy installation during a quick prototype:

```bash
sudo COURSE_WEB_PROXY_TOOL=none ./install.sh
```

If the student account is not named `student`:

```bash
sudo COURSE_TARGET_USER=alice ./install.sh
```

Log out and back in after installation so Docker and packet-capture group
membership changes apply. Rust and Lean are installed for the target user with
`rustup` and `elan`, so a new login shell also ensures `~/.cargo/bin` and
`~/.elan/bin` are on `PATH`.

## Verify

After provisioning:

```bash
check-course-environment
```

When running directly from the repository before installing the command:

```bash
./verify.sh
```

## Notes

- Do not put credentials, flags, solutions, tokens, or private keys into the VM.
- Update `software-list.md` first when adding or removing tools.
- Update `tests/expected-tools.txt` when the verification checks need to change.
