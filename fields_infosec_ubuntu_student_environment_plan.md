# Plan: Ubuntu Student Workstation Environment for the Fields Information Security Program

## 1. Purpose

Develop a standardized Ubuntu-based workstation environment that students can use throughout the program with minimal setup burden and minimal variation between student machines.

The environment should support foundational Linux and networking work, cryptography exercises, web and network security labs, cloud/infrastructure exercises, defensive-security activities, and general development tasks.

The primary student environment will be an **Ubuntu Desktop virtual machine**. Specialized target machines and architecture-sensitive labs may be provided separately.

---

## 2. Goals

The student workstation should:

- Be straightforward for students to install and launch.
- Provide the software required for the core program curriculum.
- Behave consistently across cohorts.
- Be reproducible from source-controlled configuration.
- Be testable before each program offering.
- Avoid embedding secrets, credentials, flags, or solutions.
- Support both ordinary development tasks and information-security workflows.

---

## 3. Recommended Design

### 3.1 Primary student workstation

Provide an Ubuntu Desktop LTS virtual machine containing the standard course toolset.

Intended uses include:

- Linux command-line exercises
- Python programming
- Git and course repository workflows
- Cryptography exercises
- Packet capture and network analysis
- Web-security proxying and testing
- Docker-based exercises
- Terraform and AWS CLI exercises
- Basic server configuration and defensive monitoring

### 3.2 Separate lab targets

Do not expect the student workstation to serve as every lab target.

Provide separate Ubuntu Server instances or containers where students need to:

- Configure or attack a server
- Monitor traffic on a target host
- Deploy an application
- Run a deliberately vulnerable service
- Interact with a secret-bearing CTF challenge

### 3.3 Architecture-sensitive exercises

For labs that depend on a particular processor architecture, binary format, exploit-development environment, or exact network topology, use standardized remote lab instances rather than relying on each student's local VM.

---

## 4. Key Principles

### Reproducibility

The environment should be defined by scripts and configuration files stored in a Git repository. A downloadable VM image should be an output of this process, not the master copy of the environment.

### Minimal base image

Install only tools needed across substantial parts of the program. Large, fragile, or module-specific applications should be installed separately or provided in specialized images.

### Versioned releases

Each cohort should receive a clearly named environment release, for example:

```text
Fields-InfoSec-Ubuntu-2026-v1
```

Record the installed software, setup instructions, known issues, and verification results for each release.

### No embedded secrets

The distributed environment must not contain:

- Cloud credentials
- Instructor SSH keys
- Saved authentication tokens
- Student-specific accounts
- Challenge flags or solutions
- Private assessment materials

Students should be assumed able to inspect every file in a local VM.

---

## 5. Version 1 Scope

### 5.1 Operating system

- Ubuntu Desktop LTS
- Desktop GUI available for browser-based tools, Wireshark, VS Code, and file management
- Terminal-first workflow documented for labs

### 5.2 Core development tools

Install:

```text
git
curl
wget
vim
nano
tmux
tree
jq
build-essential
python3
python3-venv
pipx
openssh-client
openssh-server
```

### 5.3 Networking tools

Install:

```text
iproute2
net-tools
dnsutils
traceroute
tcpdump
tshark
wireshark
nmap
netcat-openbsd
socat
```

### 5.4 Cryptography tools

Install:

```text
openssl
```

Provide a course Python virtual environment or documented environment setup for cryptographic Python packages required by specific exercises.

### 5.5 Web and server tools

Install or configure:

```text
nginx
Docker
Burp Suite Community or OWASP ZAP
```

The choice between Burp Suite Community and OWASP ZAP should be finalized based on the web-security labs used in the curriculum.

### 5.6 Cloud and infrastructure tools

Install:

```text
Terraform
AWS CLI
```

Credentials should always be configured by students during relevant modules and must never be built into the image.

### 5.7 Student convenience items

Provide:

- A `~/course/` directory or clear instructions for cloning course repositories.
- A `check-course-environment` verification script.
- A short welcome/readme document available inside the VM.
- Clear instructions for snapshots and recovery.
- Clear instructions on permitted updates during the program.

---

## 6. Tools Deferred from the Base Image

Do not include the following by default unless there is an immediate curricular need:

- Greenbone/OpenVAS
- GNS3
- Large wordlists
- Heavy reverse-engineering suites
- Malware-analysis tooling
- Large datasets or machine-learning environments
- Specialized exploit-development toolchains
- Course challenge servers containing secrets

These can be added as module-specific installations, separate VM images, containers, or remotely hosted environments.

---

## 7. Implementation Phases

## Phase 1: Requirements Collection

### Objective

Establish exactly which tools the first cohort needs and avoid installing unnecessary software.

### Tasks

1. List the modules that require a student technical environment.
2. For each module, identify:
   - Required software
   - Required software version, where relevant
   - Whether a GUI is required
   - Whether internet access is required
   - Whether the exercise is architecture-sensitive
   - Whether the exercise requires a target host or second machine
3. Classify each required tool as:
   - Base workstation tool
   - Module-specific installation
   - Separate local lab target
   - Remote hosted lab requirement
4. Identify student host platforms that must be supported:
   - Windows
   - Intel macOS
   - Apple Silicon macOS
   - Linux

### Deliverable

A requirements matrix mapping modules and labs to environment requirements.

---

## Phase 2: Manual Prototype

### Objective

Validate the selected toolset on a clean Ubuntu Desktop VM before investing in automation.

### Tasks

1. Create a clean Ubuntu Desktop VM.
2. Install the proposed Version 1 tools manually.
3. Run a representative sample of labs from each program area.
4. Record:
   - Installation steps
   - Package conflicts
   - Tools requiring special configuration
   - Disk and memory requirements
   - Any tools that should be deferred or moved to a separate environment

### Deliverable

A validated prototype VM and a revised list of software requirements.

---

## Phase 3: Scripted Provisioning

### Objective

Create a repeatable setup process that can configure a clean Ubuntu installation.

### Repository structure

```text
fields-infosec-student-environment/
├── README.md
├── install.sh
├── verify.sh
├── packages/
│   ├── base.sh
│   ├── networking.sh
│   ├── python.sh
│   ├── crypto.sh
│   ├── web-tools.sh
│   └── cloud-tools.sh
├── config/
│   ├── welcome.md
│   └── course-environment-version
└── tests/
    └── expected-tools.txt
```

### Tasks

1. Write `install.sh` to invoke the component installation scripts.
2. Ensure scripts are safe to rerun where practical.
3. Pin versions for tools where curriculum compatibility matters.
4. Create `verify.sh` or `check-course-environment` to check:
   - Required commands exist
   - Relevant services can start
   - Docker works
   - Python virtual environment setup works
   - Network capture tools are available
   - Terraform and AWS CLI execute
5. Run the scripts against a newly installed VM rather than only testing on the prototype.

### Deliverable

A Git repository capable of transforming a clean Ubuntu VM into the standard student workstation.

---

## Phase 4: Student Documentation

### Objective

Make installation and troubleshooting manageable for students and instructors.

### Documentation to produce

1. **Installation guide**
   - Required computer specifications
   - Virtualization software options
   - Import or installation steps
   - First login procedure

2. **Getting started guide**
   - Opening a terminal
   - Locating course files
   - Running the verification script
   - Taking a VM snapshot
   - Resetting or recovering the environment

3. **Update policy**
   - Whether students may run system upgrades
   - When updates will be required
   - How version mismatches will be handled

4. **Troubleshooting guide**
   - Virtualization disabled
   - Insufficient disk space or memory
   - Networking issues
   - Apple Silicon compatibility issues
   - Corrupted VM or failed package installation

### Deliverable

Student-facing setup documentation and an instructor troubleshooting checklist.

---

## Phase 5: Image Packaging and Distribution

### Objective

Provide students with a convenient downloadable environment while retaining the scripted source of truth.

### Tasks

1. Use the scripted provisioning process to create a clean release image.
2. Remove temporary files, caches, shell history, development credentials, and instructor-specific configuration.
3. Confirm that the image contains no private or secret material.
4. Generate release artifacts appropriate to supported hardware.
5. Publish:
   - Download instructions
   - Checksums
   - Image version
   - Minimum hardware requirements
   - Known issues
   - Verification instructions

### Possible release artifacts

```text
Fields-InfoSec-Ubuntu-2026-v1-amd64
Fields-InfoSec-Ubuntu-2026-v1-arm64
```

### Deliverable

A versioned student VM release and associated setup instructions.

---

## Phase 6: Automated Image Builds

### Objective

Move from repeatable setup scripts to a fully reproducible image-building workflow.

### Tasks

1. Select a VM image build workflow.
2. Convert the validated setup into automated image creation.
3. Ensure the build:
   - Starts from a known Ubuntu installer image
   - Runs the provisioning scripts
   - Creates a clean student account configuration
   - Produces distribution artifacts
4. Document the release procedure for future cohorts.
5. Build a release candidate and repeat acceptance testing.

### Deliverable

An automated image build process that produces the distributable VM from source-controlled configuration.

---

## 8. Testing and Acceptance Criteria

Before distribution, test the release image on representative host platforms.

### Platform testing

At minimum, test on:

- Windows host using an amd64 VM
- Intel-based macOS host, where available
- Apple Silicon macOS host using an arm64-compatible approach
- Linux host using an amd64 VM

### Environment verification

The released image should pass checks for:

- Terminal access
- Internet connectivity
- Git clone and commit workflow
- Python virtual environment creation
- OpenSSL command-line exercises
- Nmap and basic networking tools
- Wireshark or tshark packet capture
- Burp Suite Community or OWASP ZAP launch
- Nginx installation and local access
- Docker container launch
- Terraform command execution
- AWS CLI command execution without bundled credentials

### Representative lab testing

Before each cohort, run at least one representative lab from:

- Linux/networking foundations
- Cryptography
- Web security
- Offensive security
- Defensive security
- Cloud/infrastructure work

### Acceptance criteria

The environment is ready for student release when:

- All required base tools install reproducibly.
- The verification script passes on a clean build.
- Representative labs run successfully.
- No credentials, secrets, or solutions are present.
- Setup documentation has been followed successfully by someone other than the primary builder.

---

## 9. Student Distribution and Support Model

### Student onboarding workflow

A student should be able to:

1. Download or create the provided VM environment.
2. Launch the VM.
3. Log in using documented local credentials or first-boot setup.
4. Run:

```bash
check-course-environment
```

5. See a clear success result or actionable missing-tool messages.
6. Take a baseline snapshot before beginning labs.

### Support process

Maintain:

- One official image release per active cohort.
- A known-issues page.
- A small set of documented recovery procedures.
- A replacement/reset path for students whose environment becomes damaged.
- A way to distinguish environment problems from lab-content problems.

---

## 10. Risks and Mitigations

| Risk | Mitigation |
| --- | --- |
| Student devices differ significantly | Support clearly specified host/architecture paths; use remote labs where exact compatibility matters. |
| Tool upgrades break exercises | Use versioned images and a documented update policy. |
| Image becomes too large or difficult to download | Keep the base image minimal; provide heavy tools only when needed. |
| Students inspect local challenge secrets | Do not distribute secret-bearing challenges locally; host them in isolated remote lab environments. |
| Setup consumes teaching time | Provide a tested image, verification script, snapshots, and troubleshooting documentation before the first technical module. |
| Specialized tools complicate maintenance | Separate base workstation tooling from module-specific environments. |

---

## 11. Decisions to Make Early

Before building the release image, decide:

1. Which Ubuntu Desktop LTS version will be used.
2. Which virtualization platform or platforms will be officially supported.
3. Whether both amd64 and arm64 student environments will be provided.
4. Whether Burp Suite Community, OWASP ZAP, or both will be included.
5. Whether VS Code is installed inside the VM or students use host-side VS Code with remote access.
6. Which labs require separately hosted target instances.
7. Which tools must be installed in the base image versus installed during specific modules.
8. Whether students may update packages independently during the program.

---

## 12. Proposed Initial Timeline

| Milestone | Work |
| --- | --- |
| 1. Requirements matrix | Identify labs, tools, architectures, and target-host requirements. |
| 2. Manual prototype | Install Ubuntu Desktop VM and test representative tools and labs. |
| 3. Provisioning scripts | Create `install.sh` and `check-course-environment`. |
| 4. Student documentation | Draft setup, update, snapshot, and troubleshooting guides. |
| 5. Release candidate | Produce versioned VM artifacts and test on representative hosts. |
| 6. Pilot test | Have a small number of users follow the documentation from scratch. |
| 7. Final student release | Publish the approved image and support materials. |
| 8. Automated build improvement | Convert the established setup into a repeatable automated image build workflow. |

---

## 13. Immediate Next Actions

1. Create a requirements matrix for the modules planned in the next program offering.
2. Identify the first set of labs that the standard workstation must support.
3. Create a clean Ubuntu Desktop VM for prototyping.
4. Build the first draft of `install.sh`.
5. Build the first draft of `check-course-environment`.
6. Validate the environment against a small number of representative labs.
7. Revise the software list before packaging a downloadable image.

---

## 14. Desired End State

The program maintains a source-controlled student environment repository and produces a versioned Ubuntu workstation image for each cohort. Students begin with a tested, documented environment; instructors can reproduce and update it; and specialized or secret-bearing exercises run in appropriately isolated target environments rather than relying on student-local machines.
