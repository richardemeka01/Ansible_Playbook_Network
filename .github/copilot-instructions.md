# Copilot Instructions for Ansible Network Automation

## Codebase Overview
This is a multi-domain **Ansible network automation** repository containing playbooks for Cisco IOS/NX-OS device management, Palo Alto firewall configuration, and AWS/DevOps infrastructure. Three primary workstreams exist:

- **`ansible_playbook/`** - Production playbooks targeting Cisco switches (C3850, ASR, MDS) and routers
- **`Ansible_Playbook_Network/`** - Comprehensive training course materials (19 modules) progressing from basics to ServiceNow integration
- **`AWS/` & `devops/`** - Infrastructure-as-code for cloud and containerization

## Critical Architecture Patterns

### 1. **Network Device Connectivity & Credentials**
- **Connection Method**: All Cisco IOS playbooks use `connection: network_cli` (see `C3850-ios-upgrade-16.x.yml`, line 53)
- **Credential Management**: Secrets stored in `vault.yml` (Ansible Vault encrypted); playbooks reference with `vars_files: [vault.yml]`
- **Inventory Structure** (`hosts.ini`):
  - Device FQDN as inventory hostname (e.g., `AM-US-SAT_B6_TC1_RACK2_SW01.acelity.com`)
  - DNS resolution via FQDN; IP set via `ansible_host` variable
  - Grouped inventories: `[Test]` for upgrade targets, `[Networkdevices]` for discovery pool

### 2. **Multi-Play Orchestration Pattern**
Playbooks use sequential plays rather than monolithic task lists (example: `Test.yml` lines 1-146):
```yaml
- name: Check Version      # Play 1: Device fact gathering
  hosts: Test
  
- name: Create Backup      # Play 2: Localhost directory setup
  hosts: localhost
  
- name: Enable SCP         # Play 3: Protocol configuration
  hosts: Test
```
**Why**: Separates concerns (device checks → backup prep → config), enables error isolation, allows `run_once: true` on localhost tasks.

### 3. **Timeout Configuration for Long Operations**
- IOS upgrades require: `ansible_command_timeout: 1200` (20 min) in vars
- Cisco CLI commands can take 10+ minutes; always set timeout for file transfers, config commits
- See: `C3850-ios-upgrade-16.x.yml` lines 8-9

### 4. **Local Backup & Timestamp Naming**
Backup playbooks follow pattern:
1. Query `ansible_date_time.date` to create timestamped directories
2. Store as fact: `DTG: "{{ ansible_date_time.date }}"`
3. Create backup path: `/Backups/Cisco_backup/{{hostvars.localhost.DTG}}/`
4. Use `run_once: true` on localhost tasks to avoid duplication

### 5. **Palo Alto Integration**
Firewall rules use `paloaltonetworks.panos` collection (see `Palo_alto/Create application rule allowing HTTPS.yml`):
- Uses `connection: local` + `panos_security_rule` module
- Credentials from vault: `panos_username`, `panos_password`
- **Always commit**: `panos_commit` module applies changes
- Rule naming convention: `ALLOW-<PROTOCOL>-<SOURCE_ZONE>-to-<DEST_ZONE>`

## Common Workflows

### Running an IOS Upgrade
```bash
# 1. Update target version in vars
upgrade_ios_version: 16.12.11
new_ios_file_name: cat3k_caa-universalk9.16.12.11.SPA.bin

# 2. Verify inventory targets in hosts.ini [Test] group
# 3. Run with timeout override if needed
ansible-playbook C3850-ios-upgrade-16.x.yml -e ansible_command_timeout=1500
```

### Adding New Network Device
1. Add FQDN to `hosts.ini` under appropriate group
2. Set `ansible_host=<ip>` and connection vars as needed
3. Playbooks will auto-discover facts via `ios_facts` or `nxos_facts`

### Course Material Structure
Each module in `Ansible_for_Network_Engineer/` follows:
- `ansible.cfg` - Points to local `inventory` file
- `playbooks/` - Demo scripts showing concepts (roles, includes, filters)
- `inventory` - Test device FQDN list
- README guides expected outcomes

## Key Files & Examples

| Purpose | Path | Key Pattern |
|---------|------|-------------|
| Primary IOS Upgrade | `ansible_playbook/C3850-ios-upgrade-16.x.yml` | Multi-play, timeout, fact gathering |
| Palo Alto Rules | `Palo_alto/Create application rule allowing HTTPS/` | Local connection, vault credentials |
| Roles Demo | `Ansible_Playbook_Network/.../13_Reusable_.../playbooks/01_demo_role.yaml` | Demonstrates `roles:` syntax |
| Device Inventory | `ansible_playbook/hosts.ini` | FQDN + ansible_host mapping |
| Encrypted Secrets | `vault.yml` | Vault-encrypted credentials (never edit directly) |

## Development Conventions

1. **Naming**: Playbook files use descriptive names with target OS: `C3850-ios-upgrade-16.x.yml`, `nxos-upgrade2.yml`
2. **Comments**: Multi-play separation marked with `## Section Name` comment blocks
3. **Fact Registration**: Always use `register: var_name` for command outputs needed in later tasks
4. **Debugging**: Heavy use of `debug: msg:` to log intermediate values (required for network tasks)
5. **Save Configuration**: Always use `save_when: modified` in `ios_config` to avoid unnecessary commits

## Pitfalls to Avoid

- **Don't** hardcode credentials - use vault.yml + `vars_files:`
- **Don't** forget connection type for device playbooks (`connection: network_cli` for Cisco)
- **Don't** skip `gather_facts: no` on network devices (they don't support standard fact gathering)
- **Don't** omit timeout for upgrade/transfer operations
- **Don't** run backup/commit operations multiple times - use `run_once: true`

## AI Agent Productivity Notes

- For new playbooks, copy structure from `C3850-ios-upgrade-16.x.yml` template
- When modifying inventory, understand FQDN resolution occurs via `ansible_host` variable
- Capstone projects (modules 05, 09, 15, 19) show real-world integration patterns
- The course materials are **reference only** - production playbooks are in root `ansible_playbook/` directory
