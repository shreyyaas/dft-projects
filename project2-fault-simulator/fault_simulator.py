# ============================================================
# ISCAS-85 c17 Fault Simulator
# ============================================================
# Circuit: c17 (5 NAND gates, 5 inputs, 2 outputs)
# Fault model: Stuck-at-0 (SA0) and Stuck-at-1 (SA1)
# Method: Parallel fault simulation
# ============================================================

# ---- Circuit definition ----
# Each gate: (type, [input_nodes])
# Node names: I1-I5 are primary inputs, G1-G5 are gate outputs

GATES = {
    'G1': ('NAND', ['I1', 'I2']),
    'G2': ('NAND', ['I2', 'I3']),
    'G3': ('NAND', ['I4', 'I5']),
    'G4': ('NAND', ['G1', 'G2']),
    'G5': ('NAND', ['G2', 'G3']),
}

PRIMARY_INPUTS  = ['I1', 'I2', 'I3', 'I4', 'I5']
PRIMARY_OUTPUTS = ['G4', 'G5']   # O1=G4 output, O2=G5 output

# Evaluation order (topological — inputs before gates that use them)
EVAL_ORDER = ['G1', 'G2', 'G3', 'G4', 'G5']

# All nodes (wires) in the circuit — each can have SA0 or SA1
ALL_NODES = PRIMARY_INPUTS + list(GATES.keys())


# ---- Logic functions ----
def nand(a, b):
    """2-input NAND gate"""
    return int(not (a and b))


# ---- Fault-free simulation ----
def simulate(inputs: dict, fault_node=None, fault_val=None) -> dict:
    """
    Simulate c17 for a given input vector.
    Optionally inject a stuck-at fault: force fault_node to fault_val.
    Returns dict of all node values.
    """
    vals = dict(inputs)  # start with primary input values

    for gate in EVAL_ORDER:
        gate_type, gate_inputs = GATES[gate]

        # Get input values (apply fault if it's on an input wire)
        in_vals = []
        for n in gate_inputs:
            v = vals[n]
            if n == fault_node:
                v = fault_val   # stuck-at fault on this wire
            in_vals.append(v)

        # Evaluate gate
        if gate_type == 'NAND':
            result = nand(in_vals[0], in_vals[1])
        else:
            raise ValueError(f"Unknown gate type: {gate_type}")

        # Apply fault if it's on this gate's output wire
        if gate == fault_node:
            result = fault_val

        vals[gate] = result

    return vals


# ---- Generate all 32 input patterns ----
def all_input_patterns():
    """Generate all 2^5 = 32 input combinations for 5-input circuit"""
    patterns = []
    for i in range(32):
        pattern = {
            'I1': (i >> 4) & 1,
            'I2': (i >> 3) & 1,
            'I3': (i >> 2) & 1,
            'I4': (i >> 1) & 1,
            'I5': (i >> 0) & 1,
        }
        patterns.append(pattern)
    return patterns


# ---- Fault list generation ----
def generate_fault_list():
    """
    Generate all SA0 and SA1 faults for every node.
    Returns list of (node, stuck_value) tuples.
    """
    faults = []
    for node in ALL_NODES:
        faults.append((node, 0))   # SA0
        faults.append((node, 1))   # SA1
    return faults


# ---- Fault simulation ----
def run_fault_simulation(patterns, fault_list):
    """
    For each fault, check if any pattern detects it.
    A fault is detected when the faulty output differs from fault-free output.
    Returns: dict mapping (node, val) -> 'detected' or 'undetected'
    """
    results = {}

    for (fault_node, fault_val) in fault_list:
        detected = False
        detecting_pattern = None

        for pattern in patterns:
            # Fault-free simulation
            good = simulate(pattern)
            good_out = [good[o] for o in PRIMARY_OUTPUTS]

            # Faulty simulation
            bad  = simulate(pattern, fault_node=fault_node, fault_val=fault_val)
            bad_out = [bad[o] for o in PRIMARY_OUTPUTS]

            # Detection: any output differs?
            if good_out != bad_out:
                detected = True
                detecting_pattern = pattern
                break   # one detection is enough

        results[(fault_node, fault_val)] = {
            'detected': detected,
            'pattern': detecting_pattern
        }

    return results


# ---- Fault collapsing ----
def collapse_faults(fault_list, patterns):
    """
    Remove equivalent faults — faults that produce identical
    output behaviour across ALL patterns are equivalent.
    Keep only one representative per equivalence class.
    """
    # Compute output signature for each fault across all patterns
    signatures = {}
    for (node, val) in fault_list:
        sig = []
        for pattern in patterns:
            bad = simulate(pattern, fault_node=node, fault_val=val)
            sig.append(tuple(bad[o] for o in PRIMARY_OUTPUTS))
        signatures[(node, val)] = tuple(sig)

    # Group by signature — same signature = equivalent fault
    seen = {}
    collapsed = []
    for fault, sig in signatures.items():
        if sig not in seen:
            seen[sig] = fault
            collapsed.append(fault)

    return collapsed, len(fault_list) - len(collapsed)


# ---- Report generation ----
def print_report(fault_list, results, collapsed_removed):
    """Print a detailed fault coverage report"""
    detected   = [f for f in fault_list if results[f]['detected']]
    undetected = [f for f in fault_list if not results[f]['detected']]

    total      = len(fault_list)
    n_detected = len(detected)
    coverage   = (n_detected / total * 100) if total > 0 else 0

    print("=" * 60)
    print("  ISCAS-85 c17 FAULT SIMULATION REPORT")
    print("=" * 60)
    print(f"  Circuit          : c17 (5 NAND gates)")
    print(f"  Fault model      : Stuck-at (SA0 / SA1)")
    print(f"  Test patterns    : 32 (exhaustive, all 2^5)")
    print(f"  Faults removed   : {collapsed_removed} (equivalence collapsing)")
    print(f"  Faults simulated : {total}")
    print(f"  Detected         : {n_detected}")
    print(f"  Undetected       : {len(undetected)}")
    print(f"  Fault coverage   : {coverage:.1f}%")
    print("=" * 60)

    print("\n  DETECTED FAULTS:")
    print(f"  {'Fault':<20} {'Detecting pattern (I1-I5)':<30}")
    print(f"  {'-'*20} {'-'*30}")
    for fault in detected:
        node, val = fault
        p = results[fault]['pattern']
        p_str = ''.join(str(p[i]) for i in PRIMARY_INPUTS)
        print(f"  {node} SA{val:<16} {p_str}")

    if undetected:
        print(f"\n  UNDETECTED FAULTS:")
        for fault in undetected:
            node, val = fault
            print(f"  {node} SA{val}")
    else:
        print(f"\n  No undetected faults — 100% coverage achieved!")

    print("\n" + "=" * 60)


# ---- Main ----
if __name__ == '__main__':
    print("\nGenerating input patterns...")
    patterns   = all_input_patterns()

    print("Generating fault list...")
    fault_list = generate_fault_list()
    print(f"  Total faults before collapsing: {len(fault_list)}")

    print("Performing fault collapsing...")
    collapsed_faults, removed = collapse_faults(fault_list, patterns)
    print(f"  Faults after collapsing: {len(collapsed_faults)} ({removed} removed)")

    print("Running fault simulation...")
    results = run_fault_simulation(patterns, collapsed_faults)

    print_report(collapsed_faults, results, removed)
