# Microprocessor Design

This project involves designing a microprocessor. It provides an opportunity to become familiar with the design, simulation, synthesis, and physical implementation of complex digital systems using automated design tools. This project follows the standard design flow. Specifically, it involved:

- Designing a processor model using the **VHDL** language.
- Performing simulations:
  - **Behavioral** (VHDL model).
  - **Timing** (post-synthesis and post-implementation netlist) of the processor.
- Performing the **logical synthesis** of the processor using the **45 nm** technology from the **GPDK045** kit.
- Performing **automatic placement and routing** from the post-synthesis netlist of the processor.

The software and technologies used are provided by [CMC](https://www.cmc.ca/WhatWeOffer/Products/CMC-00200-04870.aspx). The reference kit is based on the **Cadence** educational 45 nm technology: *Generic Process Design Kit* [GPDK045](https://www.cmc.ca/WhatWeOffer/Products/CMC-00200-04870.aspx).

The following figure presents the processor pipeline:

![Pipeline](doc/pipeline.png "Pipeline")
