

module cpu(
    input clk,
    input run,
    input reset,
    input [15:0] d_inst,

    output reg [3:0] mux_sel,
    output reg done,

    output reg [2:0] sel,
    output reg en_s,
    output reg en_c,
    output reg [7:0] en,
    output reg en_inst,
    output [15:0] im_d
);

    
 
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;


    reg [1:0] cur_state, next_state;
    wire [1:0] format;
    assign format = d_inst[1:0];
    

    always @(*) begin
        if(reset == 1) begin
            en_s = 0;
            en_c = 0;
            done = 0;
            sel = 3'b0;
            en = 8'b0;
            en_inst = 0;
            mux_sel = 4'b0000;
        end
        else begin
            en_inst = 1;
            en_s = 0;
            en_c = 0;
            done = 0;
            mux_sel = 4'b1001;
            sel = 3'b0;
            en = 8'b0;
            case (cur_state)
                S0: begin
                    if(format!=2'b10) begin
                        en_s = 1;
                        mux_sel = {1'b0,d_inst[15:13]};
                        if(format == 2'b01) begin
                            im_d = {8'b0, d_inst[12:5]}; 
                        end
                        else begin
                            im_d = 16'b0;
                        end
                    end
                    else begin
                        en_s = 0;
                        mux_sel = 4'b1001;
                        im_d = 16'b0;
                    end
                    done = 0;
                    en_inst = 1;
                end
                S1: begin
                    if(format!=2'b10) begin
                        if(format == 2'b00) begin
                            mux_sel = {1'b0, d_inst[12:10]};
                        end
                        else if(format == 2'b01) begin
                            mux_sel = 4'b1000;
                        end
                        else begin
                            mux_sel = 4'b1001;
                        end
                        sel = d_inst[4:2];
                    end
                    else begin
                        mux_sel = 4'b0001;
                        sel = 3'b0;
                    end
                    en_inst = 0;
                    en_c = 1;
                end

                S2: begin            
                    if (format!=2'b10) begin
                        en[d_inst[15:13]] = 1;
                    end
                    else begin
                        en = 8'b0;
                    end
                    done = 1;
                end
                default: begin
                    en_s = 0;
                    en_c = 0;
                    done = 0;
                    sel = 3'b0;
                    en = 8'b0;
                end
            endcase
        end
    end

    // Next state sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cur_state <= S0;
        end 

        else begin
            cur_state <= next_state;
        end

    end

    // Next state combinational logic
    always @(*) begin
        case (cur_state)
            S0: next_state = (run==1) ? S1:S0;
            S1: next_state = (en_c==1) ? S2:S1;
            S2: next_state = (done == 1) ? S0 : S2;
            default: next_state = S0;
        endcase
    end

endmodule
