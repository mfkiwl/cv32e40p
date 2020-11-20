
module cv32e40n_apu_dummy import cv32e40p_apu_core_pkg::*;
   (input  logic                            clk_i,
    input  logic                            rst_ni,
    
    // request channel
    input  logic [APU_NARGS_CPU-1:0][31:0]  apu_operands_i,
    input  logic [APU_WOP_CPU-1:0]          apu_op_i,
    input  logic [APU_NDSFLAGS_CPU-1:0]     apu_flags_i,
    input  logic                            apu_req_i,
    // response channel
    output logic                            apu_rvalid_o,
    output logic [31:0]                     apu_result_o,
    output logic [APU_NUSFLAGS_CPU-1:0]     apu_flags_o,
    output logic                            apu_gnt_o);

    assign apu_result_o = 'd0;
    assign apu_flags_o  = 'd0;

    typedef enum {IDLE, PROC, VALID} responder_state;
    responder_state current_s, next_s;

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(~rst_ni)
            current_s <= IDLE;
        else
            current_s <= next_s;
    end

    always_comb begin
        apu_gnt_o = '0;
        apu_rvalid_o = '0;

        case(current_s)
            IDLE: begin
                apu_gnt_o = '1;
                apu_rvalid_o = '0;

                if(apu_req_i) // Do we have a transaction request?
                    next_s = PROC;
                else
                    next_s = IDLE;
            end
            PROC: begin
                apu_gnt_o = '0;
                apu_rvalid_o = '0;

                next_s = VALID; // Single Cycle Instruction
            end
            VALID: begin
                apu_gnt_o = '0;
                apu_rvalid_o = '1;

                next_s = IDLE;
            end
        endcase
    end

endmodule