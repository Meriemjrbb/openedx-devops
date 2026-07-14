# Fix Plan: Open edX DevOps — Issues Resolution

## Context
Real VM at 188.40.148.147 (Ubuntu 22.04, 5.8GB RAM, 20GB disk). SSH works with `~/.ssh/openedx_stage_ed25519`.
Mariem's WP-01/02 mostly done. Taieb hasn't started Tutor/Open edX config. Adrian's Ansible skeleton needs validation.

## Issues & Fixes (in execution order)

### 1. Docker registry mirror (Critical — blocks everything)
**File:** `ansible/roles/docker/defaults/main.yml`
**Change:** Add `registry-mirrors: ["https://mirror.gcr.io"]` to `docker_daemon_options`

### 2. Duplicate Docker repos (Medium)
**File:** `ansible/roles/docker/tasks/main.yml`
**Change:** Add task to remove legacy `/etc/apt/sources.list.d/docker.list` before creating deb822 repo

### 3. Swap file — 2GB (Medium, risk R3)
**File:** `ansible/roles/vm_prep/tasks/main.yml`
**Change:** Add tasks to create 2GB swap file at `/swapfile` (fallocate, chmod 600, mkswap, swapon, add to /etc/fstab)
**File:** `ansible/roles/vm_prep/defaults/main.yml`
**Change:** Add `vm_prep_swap_size_mb: 2048` and `vm_prep_swap_path: /swapfile` variables

### 4. Unattended-upgrades service (Low)
**File:** `ansible/roles/vm_prep/tasks/main.yml`
**Change:** Add task to enable and start `unattended-upgrades` service

### 5. Execution against real VM
```bash
# Step 1: vm_prep (check mode)
set -a; source .env; set +a
cd ansible && ansible-playbook --tags vm_prep --check site.yml

# Step 2: vm_prep (real run)
ansible-playbook --tags vm_prep site.yml

# Step 3: docker (check mode)
ansible-playbook --tags docker --check site.yml

# Step 4: docker (real run)
ansible-playbook --tags docker site.yml

# Step 5: Test Docker Hub with mirror
ssh ... "docker pull hello-world"

# Step 6: Idempotence test (second run, expect changed=0)
ansible-playbook --tags vm_prep,docker site.yml

# Step 7: Tutor install (skip config save — waiting for Taieb's values)
ansible-playbook --tags tutor -e "tutor_lms_host=PLACEHOLDER tutor_cms_host=PLACEHOLDER" site.yml
```

### 6. Git hygiene
- Stage `.gitignore` change (adds `.sessions/`)
- Merge `feature/ansible-skeleton` into `main` once validated
- Commit with descriptive message

## Files to modify
1. `ansible/roles/docker/defaults/main.yml` — add registry mirror
2. `ansible/roles/docker/tasks/main.yml` — remove legacy docker.list
3. `ansible/roles/vm_prep/defaults/main.yml` — add swap variables
4. `ansible/roles/vm_prep/tasks/main.yml` — add swap + unattended-upgrades tasks

## Out of scope
- Terraform (teammate's domain)
- Tutor config values (waiting for Taieb)
- WP-08 CI/CD deployment workflow (needs working playbooks first)
