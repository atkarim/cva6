
// Author: Florian Zaruba, ETH Zurich
// Date: 19.04.2017
// Description: Instantiation of all functional units residing in the execute stage
//
// Copyright (C) 2017 ETH Zurich, University of Bologna
// All rights reserved.
//
// This code is under development and not yet released to the public.
// Until it is released, the code is under the copyright of ETH Zurich and
// the University of Bologna, and may contain confidential and/or unpublished
// work. Any reuse/redistribution is strictly forbidden without written
// permission from ETH Zurich.
//
// Bug fixes and contributions will eventually be released under the
// SolderPad open hardware license in the context of the PULP platform
// (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
// University of Bologna.
//
import ariane_pkg::*;

module ex_stage #(
        parameter int ASID_WIDTH = 1
    )(
    input  logic                                   clk_i,    // Clock
    input  logic                                   rst_ni,   // Asynchronous reset active low
    input  logic                                   flush_i,

    input  fu_op                                   operator_i,
    input  logic [63:0]                            operand_a_i,
    input  logic [63:0]                            operand_b_i,
    input  logic [63:0]                            operand_c_i,
    input  logic [63:0]                            imm_i,
    input  logic [TRANS_ID_BITS-1:0]               trans_id_i,
    input  logic [63:0]                            pc_i,                  // PC of current instruction
    input  logic                                   is_compressed_instr_i, // we need to know if this was a compressed instruction
                                                                          // in order to calculate the next PC on a mis-predict
    // ALU 1
    output logic                                   alu_ready_o,           // FU is ready
    input  logic                                   alu_valid_i,           // Output is valid
    output logic                                   alu_valid_o,           // ALU result is valid
    output logic [63:0]                            alu_result_o,
    output logic [TRANS_ID_BITS-1:0]               alu_trans_id_o,        // ID of scoreboard entry at which to write back
    output exception                               alu_exception_o,
    // Branches and Jumps
    input  logic                                   branch_valid_i,        // we are using the branch unit
    input  branchpredict_sbe                       branch_predict_i,      // branch prediction in
    output branchpredict                           resolved_branch_o,     // the branch engine uses the write back from the ALU
    output logic                                   resolve_branch_o,      // to ID signaling that we resolved the branch
    // LSU
    output logic                                   lsu_ready_o,           // FU is ready
    input  logic                                   lsu_valid_i,           // Input is valid
    output logic                                   lsu_valid_o,           // Output is valid
    output logic [63:0]                            lsu_result_o,
    output logic [TRANS_ID_BITS-1:0]               lsu_trans_id_o,
    input  logic                                   lsu_commit_i,
    output exception                               lsu_exception_o,
    // CSR
    output logic                                   csr_ready_o,
    input  logic                                   csr_valid_i,
    output logic [TRANS_ID_BITS-1:0]               csr_trans_id_o,
    output logic [63:0]                            csr_result_o,
    output logic                                   csr_valid_o,
    output logic [11:0]                            csr_addr_o,
    input  logic                                   csr_commit_i,
    // memory management
    input  logic                                   enable_translation_i,
    input  logic                                   fetch_req_i,
    output logic                                   fetch_gnt_o,
    output logic                                   fetch_valid_o,
    output logic                                   fetch_err_o,
    input  logic [63:0]                            fetch_vaddr_i,
    output logic [31:0]                            fetch_rdata_o,
    input  priv_lvl_t                              priv_lvl_i,
    input  logic                                   flag_pum_i,
    input  logic                                   flag_mxr_i,
    input  logic [37:0]                            pd_ppn_i,
    input  logic [ASID_WIDTH-1:0]                  asid_i,
    input  logic                                   flush_tlb_i,

    output logic [63:0]                            instr_if_address_o,
    output logic                                   instr_if_data_req_o,
    output logic [3:0]                             instr_if_data_be_o,
    input  logic                                   instr_if_data_gnt_i,
    input  logic                                   instr_if_data_rvalid_i,
    input  logic [31:0]                            instr_if_data_rdata_i,

    output logic [63:0]                            data_if_address_o,
    output logic [63:0]                            data_if_data_wdata_o,
    output logic                                   data_if_data_req_o,
    output logic                                   data_if_data_we_o,
    output logic [7:0]                             data_if_data_be_o,
    output logic [1:0]                             data_if_tag_status_o,
    input  logic                                   data_if_data_gnt_i,
    input  logic                                   data_if_data_rvalid_i,
    input  logic [63:0]                            data_if_data_rdata_i,

    // MULT
    output logic                                   mult_ready_o,      // FU is ready
    input  logic                                   mult_valid_i       // Output is valid
);

    // -----
    // ALU
    // -----
    alu alu_i (
        .result_o            ( alu_result_o                 ),
        .*
    );

    // --------------------
    // Branch Engine
    // --------------------
    branch_unit branch_unit_i (
        .fu_valid_i          ( alu_valid_i & lsu_valid_i & csr_valid_i ),
        .valid_i             ( branch_valid_i                          ),
        .branch_ex_o         ( alu_exception_o                         ), // we use the ALU exception WB for the branch exception
        .*
    );

    // ----------------
    // Multiplication
    // ----------------
    // TODO

    // ----------------
    // Load-Store Unit
    // ----------------
    lsu lsu_i (
        .commit_i  ( lsu_commit_i ),
        .*
    );

    // -----
    // CSR
    // -----
    // CSR address buffer
    csr_buffer csr_buffer_i (
        .commit_i ( csr_commit_i  ),
        .*
    );


endmodule