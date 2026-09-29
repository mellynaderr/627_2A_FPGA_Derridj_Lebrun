# Documentation FPGA – Configuration des pins d'horloge

## FPGA utilisé 

Le FPGA utilisé est le suivant : `5CSEBA6U23I7`

## Pin Assignment of Clock Inputs (Table 3-5)

Documentation de référence fournie en annexe pour la configuration des pins de la clock sur notre FPGA.
Q.1 

| Signal Name   | FPGA Pin No. | Description                                | I/O Standard |
|---------------|--------------|--------------------------------------------|--------------|
| FPGA_CLK1_50  | PIN_V11      | 50 MHz clock input                         | 3.3V         | <- Clock qui nous intéresse>
| FPGA_CLK2_50  | PIN_Y13      | 50 MHz clock input                         | 3.3V         |



Pins utilisés pour le chenillard (issue de Quartus planner  ) : 

| Node Name | Direction | Location | I/O Bank | VREF Group | Fitter Location | I/O Standard | Reserved | Current Strength | Slew Rate |
|-----------|-----------|----------|----------|------------|-----------------|--------------|----------|------------------|-----------|
| led[0]    | Output    | PIN_AG28 | 4A       | B4A_N0     | PIN_AG28        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[1]    | Output    | PIN_AE25 | 5A       | B5A_N0     | PIN_AE25        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[2]    | Output    | PIN_AE26 | 4A       | B4A_N0     | PIN_AE26        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[3]    | Output    | PIN_AG25 | 4A       | B4A_N0     | PIN_AG25        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[4]    | Output    | PIN_AG23 | 4A       | B4A_N0     | PIN_AG23        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[5]    | Output    | PIN_AH21 | 4A       | B4A_N0     | PIN_AH21        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[6]    | Output    | PIN_AF22 | 4A       | B4A_N0     | PIN_AF22        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[7]    | Output    | PIN_AG20 | 4A       | B4A_N0     | PIN_AG20        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[8]    | Output    | PIN_AG18 | 4A       | B4A_N0     | PIN_AG18        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| led[9]    | Output    | PIN_AG15 | 4A       | B4A_N0     | PIN_AG15        | 2.5 V        |          | 12mA (default)   | 1 (default) |
| rst_n     | Input     | PIN_AH27 | 4A       | B4A_N0     | PIN_AH27        | 2.5 V        |          | 12mA (default)   |           |
| clk       | Input     | PIN_V11  | 3B       | B3B_N0     | PIN_V11         | 2.5 V        |          | 12mA (default)   |           |

