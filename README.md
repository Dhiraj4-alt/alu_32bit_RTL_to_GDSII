# 32-bit Combinational ALU — RTL to GDSII (Sky130)

This repository presents the complete **RTL-to-GDSII implementation** of a
32-bit **combinational Arithmetic Logic Unit (ALU)** using the Sky130
standard cell library.

The intent of this project is to demonstrate a **full standard-cell VLSI
design flow** on a realistic digital block, while clearly showing how
logical design decisions propagate through synthesis, placement, routing,
and sign-off.

The flow covered in this project is:

**RTL Design → Logic Synthesis → Floorplanning → Placement →  
Clock Tree Synthesis → Routing → Sign-Off (GDSII)**

Each stage below explains:
- what is happening at that step,
- why that step is required,
- what to observe in the generated reports and layouts,
- and how it impacts the next stage in the flow.

---

<details>
<summary><strong>1. RTL Design</strong></summary>

### Design Intent
The Arithmetic Logic Unit (ALU) is a **purely combinational block** that
performs arithmetic and logical operations based on a control input
(opcode). Outputs depend only on the current inputs, with no clock or
state-holding elements.

This design was intentionally kept **fully combinational** to build a
clean and well-understood baseline before moving to registered or
pipelined architectures.

---

### RTL Implementation
The ALU was implemented in Verilog  
(`rtl/alu_32bit.v`) with the following characteristics:

- 32-bit wide datapath
- Opcode-driven operation selection using a `case` statement
- `always @(*)` used to enforce combinational behavior
- Default assignments to prevent unintended latch inference

RTL structure and opcode decoding can be visualized here:

- RTL structure:  
  ![RTL](docs/alu_32bit_RTL.png)

- Opcode decoding:  
  ![Opcode RTL](docs/opecode_RTL.png)

---

### Tools Used
- RTL compilation & simulation: **Icarus Verilog (`iverilog`)**

---

### Supported Operations

| Opcode | Operation |
|------|----------|
| 000  | ADD |
| 001  | SUB |
| 010  | AND |
| 011  | OR  |
| 100  | XOR |
| 101  | NAND |
| 110  | NOT (Unary on A) |
| 111  | PASS A |

---

### Key Observations
- Carry-out is derived using a wider intermediate sum
- Signed overflow is explicitly handled for ADD and SUB
- Zero flag is asserted by comparing the final output to zero

These signals are essential for later processor or datapath integration.

</details>

---

<details>
<summary><strong>2. Functional Verification</strong></summary>

### Verification Approach
Functional verification ensures the RTL behaves correctly **before**
synthesis and physical design. Only logical correctness is verified at
this stage.

---

### Methodology
- A self-written Verilog testbench was used
- All opcodes were exercised using deterministic test vectors
- Status flags (zero, carry, overflow) were monitored
- Waveforms were generated for detailed inspection

---

### Tools Used
- Waveform viewer: **GTKWave**

---

### Waveform Analysis
![GTKWave](docs/Simulation_GTKwave.png)

What to observe in this waveform:
- Opcode transitions directly select the intended operation
- Arithmetic results propagate without clock dependency
- Carry and overflow assert only for valid arithmetic cases
- Zero flag asserts exactly when the output becomes zero

Example:
- At 0–10 ns, **A = 00000005**, **B = 00000003**, opcode **000 (ADD)**  
  produces output **00000008**
- Subsequent vectors use large hexadecimal values to validate bitwise
  logic and arithmetic robustness

Successful verification here confirms the RTL is ready for synthesis.

</details>

---

<details>
<summary><strong>3. Logic Synthesis</strong></summary>

### Synthesis Overview
Logic synthesis maps the verified RTL into a **gate-level netlist**
using a technology library. RTL constructs are replaced with
technology-specific standard cells.

---

### Tools Used
- Synthesis engine: **Yosys**
- Target library: **Sky130 standard cell library**

---

### Synthesis Results

<details>
<summary><strong>Synthesized Netlist Structure (Expanded View)</strong></summary>

![Synth Netlist Graph](docs/06_synth_netlist_graph.png)

</details>


This confirms:
- successful technology mapping,
- exclusive use of Sky130 standard cells,
- correct translation of arithmetic and logic operations.

---

**Netlist Graph**
![Netlist Graph](docs/06_synth_netlist_graph.png)

This graph highlights:
- logic depth,
- opcode decode fanout,
- arithmetic datapath complexity.

---

**Synthesis Statistics**
![Stats](docs/Yosys_stats_01.png)  
![Stats](docs/Yosys_stats_02.png)

These reports show:
- total number of standard cells,
- distribution of logic gates,
- relative complexity of the design.

Detailed report:  
[`01_yosys_stat_summary.txt`](reports/01_yosys_stat_summary.txt)

---

### Key Observations
- The netlist is fully combinational
- No sequential elements were inferred
- Switching activity dominates power estimation

The synthesized netlist is now ready for physical design.

</details>

---

<details>
<summary><strong>4. Floorplanning</strong></summary>

### Purpose
Floorplanning defines the **physical dimensions** of the design,
including die area, core area, and utilization.

---

### Floorplan View
![Core and Die](docs/Core%20and%20die.png)

What to observe:
- Die boundary enclosing the design (Green end-end)
- Core region allocated for standard cells(Blue regions)

---

### Report
- [`02_floorplan_final.rpt`](reports/02_floorplan_final.rpt)

---

### Key Observations
- Compact core area suitable for a combinational block
- Moderate utilization enables smooth placement and routing

</details>

---

<details>
<summary><strong>5. Placement</strong></summary>

### Placement Overview
Placement assigns exact physical locations to all standard cells while
optimizing wirelength, congestion, and timing.

---

### Placement Views
![Placement 1](docs/CellsPlaced.1.png)  
![Placement 2](docs/Cellsplaced2.png)

What to observe:
- Even distribution of cells
- No dense clusters or congestion hotspots
- Logical structure preserved spatially

---

### Reports
- [`3_global_place.rpt`](reports/3_global_place.rpt)
- [`3_detailed_place.rpt`](reports/3_detailed_place.rpt)

---

### Key Observations
- Balanced placement prepares the design for CTS and routing
- No placement-related violations observed

</details>

---

<details>
<summary><strong>6. Clock Tree Synthesis (CTS)</strong></summary>

### CTS Context
Although this design is **fully combinational**, CTS was executed to
maintain a complete RTL-to-GDSII flow.

---

### Clock View
![CTS](docs/final_clocks.webp)

What to observe:
- Minimal clock infrastructure
- No clock skew paths due to absence of registers

---

### Report
- [`4_cts_final.rpt`](reports/4_cts_final.rpt)

---

### Key Observations
- No launch or capture paths
- Clock power is negligible
- Expected behavior for a combinational design

</details>

---

<details>
<summary><strong>7. Routing</strong></summary>

### Routing Overview
Routing connects all placed cells using available metal layers while
meeting DRC and electrical constraints.

---

### Routing Views
![Routing](docs/final_routing.webp)  
![Congestion](docs/final_congestion.webp)

What to observe:
- Clean interconnect across metal layers
- No congestion hotspots (no red regions)

---

### Reports
- [`5_global_route.rpt`](reports/5_global_route.rpt)
- [`5_detailed_route.rpt`](reports/5_detailed_route.rpt)
- [`5_route_drc.rpt`](reports/5_route_drc.rpt)

---

### Key Observations
- Routing completed without violations
- Adequate metal utilization

</details>

---

<details>
<summary><strong>8. Sign-Off Analysis (GDSII)</strong></summary>

### Final Layout
![Final Layout](docs/GDSfinal_Lyout.png)  
![Final All](docs/final_all.webp)

These images represent the fully placed and routed design, equivalent
to the final GDSII database.

---

### Power Integrity
![IR Drop](docs/final_ir_drop.webp)

What to observe:
- Uniform power distribution
- No critical voltage drop regions

---

### Reports
- [`3_resizer.rpt`](reports/3_resizer.rpt)
- [`6_finish.rpt`](reports/6_finish.rpt)

---

### Final Observations
- WNS = 0, TNS = 0
- No setup or hold violations
- No DRC or electrical violations
- Entirely combinational power profile

The design successfully completes the full **RTL-to-GDSII flow** and
serves as a solid baseline for future registered or pipelined designs.

</details>

