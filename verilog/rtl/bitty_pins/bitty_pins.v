/* verilator lint_off MODDUP */
module bitty_pins #(
    parameter BITS = 16
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i, // Verilator lint_off UNUSED
    input wb_rst_i,// Verilator lint_off UNUSED
    input wbs_stb_i,// Verilator lint_off UNUSED
    input wbs_cyc_i,// Verilator lint_off UNUSED
    input wbs_we_i,// Verilator lint_off UNUSED
    input [3:0] wbs_sel_i,// Verilator lint_off UNUSED
    input [31:0] wbs_dat_i,// Verilator lint_off UNUSED
    input [31:0] wbs_adr_i,// Verilator lint_off UNUSED
    output wbs_ack_o,// Verilator lint_off UNUSED
    output [31:0] wbs_dat_o, // to communicate with other components within a chip

    // Logic Analyzer Signals ->
    input  [127:0] la_data_in,// Verilator lint_off UNUSED
    output [127:0] la_data_out,// Verilator lint_off UNUSED
    input  [127:0] la_oenb,// Verilator lint_off UNUSED

    // IOs
    input  [BITS-1:0] io_in,// Verilator lint_off UNUSED
    output [BITS-1:0] io_out,// Verilator lint_off UNUSED
    output [BITS-1:0] io_oeb,// Verilator lint_off UNUSED

    // IRQ
    output [2:0] irq // Verilator lint_off UNUSED
);
    wire clk;
    wire rst;

    wire [BITS-1:0] rdata; 
    wire [BITS-1:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [BITS-1:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; //both are high when tranaction of WBS starts
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};//specify which bytes in word are active during yhe transaction
    assign wbs_dat_o = {{(32-BITS){1'b0}}, rdata};
    assign wdata = wbs_dat_i[BITS-1:0];

    // IO
    assign io_out = count; //to observe the value externally
    assign io_oeb = {(BITS){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(128-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    assign la_write = ~la_oenb[63:64-BITS] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

    always @(posedge clk) begin
        
    end

    wire d_instr = 16'b0;

    bigger instance_bigger(
        .run(1'b1),
        .clk(clk),
        .reset(rst),
        .done(wbs_ack_o),
        .instr(d_instr),//should be replaced with another pin/port
        .d_out(io_out)
    );

endmodule
