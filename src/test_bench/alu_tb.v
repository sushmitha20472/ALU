`timescale 1ns/1ps

module alu_tb;

    reg [7:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [3:0] CMD;
    reg [1:0] INP_VALID;

    wire [15:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    wire [15:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

    alu dut (
        .OPA(OPA), .OPB(OPB), .CIN(CIN), .CLK(CLK), .RST(RST),
        .CMD(CMD), .CE(CE), .MODE(MODE), .INP_VALID(INP_VALID),
        .COUT(COUT_dut), .OFLOW(OFLOW_dut), .RES(RES_dut),
        .G(G_dut), .E(E_dut), .L(L_dut), .ERR(ERR_dut)
    );

    alu_reference_model ref_model (
        .OPA(OPA), .OPB(OPB), .CIN(CIN), .MODE(MODE),
        .CMD(CMD), .INP_VALID(INP_VALID),
        .RES(RES_ref), .COUT(COUT_ref), .OFLOW(OFLOW_ref),
        .G(G_ref), .E(E_ref), .L(L_ref), .ERR(ERR_ref)
    );

    initial begin CLK = 0; forever #5 CLK = ~CLK; end

    initial begin

        RST = 1; CE = 1; CIN = 0; MODE = 0;
        CMD = 0; OPA = 0; OPB = 0; INP_VALID = 2'b00;
        @(posedge CLK); RST = 0; @(posedge CLK);

//CE
        $display("\n CE TESTS");
        MODE = 1; INP_VALID = 2'b11;
        CE = 1;
        apply_test(8'd5, 8'd5, 4'd0, "CE(ce_enable)");
        CE = 0;
        apply_test(8'd9, 8'd1, 4'd0, "CE(ce_disable_hold)");
        CE = 1;

//MODE
        $display("\n MODE TESTS");
        INP_VALID = 2'b11;
        MODE = 1; apply_test(8'd10, 8'd5, 4'd0, "MODE(mode_high_arithmetic)");
        MODE = 0; apply_test(8'd10, 8'd5, 4'd0, "MODE(mode_low_logical)");
        MODE = 1; apply_test(8'd10, 8'd5, 4'd0, "MODE(mode_switch_arith)");
        MODE = 0; apply_test(8'd10, 8'd5, 4'd0, "MODE(mode_switch_logic)");

//VALID CMD
        $display("\nINVALID CMD TESTS ");
        INP_VALID = 2'b11;
        MODE = 1;
        apply_test(8'd10, 8'd10, 4'd13, "INVALID_CMD(invalid_cmd_mode1)");
        MODE = 0;
        apply_test(8'd10, 8'd10, 4'd14, "INVALID_CMD(invalid_cmd_mode0)");

//VALID INPUT
        $display("\nINPUT VALIDATION (INP_VALID=00)");
        INP_VALID = 2'b00;
        MODE = 1;
        apply_test(8'd5, 8'd5, 4'd0,  "INP_VALID(invalid_input_add)");
        apply_test(8'd5, 8'd5, 4'd1,  "INP_VALID(invalid_input_sub)");
        apply_test(8'd5, 8'd5, 4'd2,  "INP_VALID(invalid_input_add_cin)");
        apply_test(8'd5, 8'd5, 4'd3,  "INP_VALID(invalid_input_sub_cin)");
        apply_test(8'd5, 8'd5, 4'd4,  "INP_VALID(invalid_input_inc_a)");
        apply_test(8'd5, 8'd5, 4'd5,  "INP_VALID(invalid_input_dec_a)");
        apply_test(8'd5, 8'd5, 4'd6,  "INP_VALID(invalid_input_inc_b)");
        apply_test(8'd5, 8'd5, 4'd7,  "INP_VALID(invalid_input_dec_b)");
        apply_test(8'd5, 8'd5, 4'd8,  "INP_VALID(invalid_input_cmp)");
        apply_test(8'd5, 8'd5, 4'd9,  "INP_VALID(invalid_input_inc_mul)");
        apply_test(8'd5, 8'd5, 4'd10, "INP_VALID(invalid_input_shift_mul)");
        apply_test(8'd5, 8'd5, 4'd11, "INP_VALID(invalid_input_signed_add)");
        apply_test(8'd5, 8'd5, 4'd12, "INP_VALID(invalid_input_signed_sub)");
        MODE = 0;
        apply_test(8'd5, 8'd5, 4'd0,  "INP_VALID(invalid_input_and)");
        apply_test(8'd5, 8'd5, 4'd1,  "INP_VALID(invalid_input_nand)");
        apply_test(8'd5, 8'd5, 4'd2,  "INP_VALID(invalid_input_or)");
        apply_test(8'd5, 8'd5, 4'd3,  "INP_VALID(invalid_input_nor)");
        apply_test(8'd5, 8'd5, 4'd4,  "INP_VALID(invalid_input_xor)");
        apply_test(8'd5, 8'd5, 4'd5,  "INP_VALID(invalid_input_xnor)");
        apply_test(8'd5, 8'd5, 4'd6,  "INP_VALID(invalid_input_not_a)");
        apply_test(8'd5, 8'd5, 4'd7,  "INP_VALID(invalid_input_not_b)");
        apply_test(8'd5, 8'd5, 4'd8,  "INP_VALID(invalid_input_shr_a)");
        apply_test(8'd5, 8'd5, 4'd9,  "INP_VALID(invalid_input_shl_a)");
        apply_test(8'd5, 8'd5, 4'd10, "INP_VALID(invalid_input_shr_b)");
        apply_test(8'd5, 8'd5, 4'd11, "INP_VALID(invalid_input_shl_b)");
        apply_test(8'd5, 8'd5, 4'd12, "INP_VALID(invalid_input_rol)");
        apply_test(8'd5, 8'd5, 4'd13, "INP_VALID(invalid_input_ror)");

//ADD
        $display("\nADD TESTS");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd2,   8'd4,   4'd0, "ADD(add_both_normal)");
        apply_test(8'd255, 8'd255, 4'd0, "ADD(add_max)");
        apply_test(8'd0,   8'd0,   4'd0, "ADD(add_only_zeros)");
        CIN = 1;
        apply_test(8'd2,   8'd4,   4'd0, "ADD(add_with_cin)");
        CIN = 0;
        INP_VALID = 2'b10;
        apply_test(8'd2,   8'd4,   4'd0, "ADD(add_invalid_input)");
	INP_VALID = 2'b01;
	apply_test(8'd2,   8'd4,   4'd0, "ADD(add_invalid_input)");

//SUB
        $display("\n SUB TESTS");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd50,  8'd20,  4'd1, "SUB(sub_normal)");
        apply_test(8'd10,  8'd20,  4'd1, "SUB(sub_oflow)");
        apply_test(8'd0,   8'd0,   4'd1, "SUB(sub_zeros)");
        apply_test(8'd255, 8'd255, 4'd1, "SUB(sub_max)");
        apply_test(8'd30,  8'd30,  4'd1, "SUB(sub_equal_operands)");
        INP_VALID = 2'b10;
        apply_test(8'd50,  8'd20,  4'd1, "SUB(sub_invalid)");
	INP_VALID = 2'b10;
	apply_test(8'd2,   8'd4,   4'd0, "SUB(sub_invalid_input)");

//ADD CIN
        $display("\nADD_CIN TESTS");
        MODE = 1; INP_VALID = 2'b11; CIN = 1;
        apply_test(8'd10,  8'd20,  4'd2, "ADD_CIN(add_cin_normal)");
        apply_test(8'd255, 8'd0,   4'd2, "ADD_CIN(add_cin_with_cout)");
        apply_test(8'd255, 8'd255, 4'd2, "ADD_CIN(add_cin_max)");
        apply_test(8'd0,   8'd0,   4'd2, "ADD_CIN(add_cin_zero)");
        INP_VALID = 2'b10;
        apply_test(8'd1,   8'd1,   4'd2, "ADD_CIN(add_cin_invalid)");
        CIN = 0;
	INP_VALID = 2'b01;
	apply_test(8'd2,   8'd4,   4'd0, "ADD_CIN(add__cin_invalid)");

//SUB CIN
        $display("\nSUB_CIN TESTS");
        MODE = 1; INP_VALID = 2'b11; CIN = 1;
        apply_test(8'd50,  8'd20,  4'd3, "SUB_CIN(sub_cin_normal)");
        apply_test(8'd0,   8'd0,   4'd3, "SUB_CIN(sub_cin_oflow)");
	apply_test(8'd1,   8'd2,   4'd3, "SUB_CIN(sub_cin_oflow)");
	apply_test(8'd20,  8'd20,  4'd3, "SUB_CIN(sub_cin_equal_borrow)");
        apply_test(8'd1,   8'd0,   4'd3, "SUB_CIN(sub_cin_boundary_zero)");
	INP_VALID = 2'b01;
	apply_test(8'd10,  8'd5,   4'd3, "SUB_CIN(sub_cin_invalid)");
	INP_VALID = 2'b10;
	apply_test(8'd10,  8'd5,   4'd3, "SUB_CIN(sub_cin_invalid)");
        CIN = 0;

//INC A
        $display("\nINC_A TESTS");
        MODE = 1;
        INP_VALID = 2'b01;
        apply_test(8'd20,  8'd0, 4'd4, "INC_A(inc_a_normal)");
        apply_test(8'd255, 8'd0, 4'd4, "INC_A(inc_a_out_of_range)");
        INP_VALID = 2'b10;
        apply_test(8'd1,   8'd0, 4'd4, "INC_A(inc_a_invalid)");
	INP_VALID = 2'b11;
	apply_test(8'd20,  8'd0, 4'd4, "INC_A(inc_a_normal)");
	


//DEC A
        $display("\n DEC_A TESTS");
        MODE = 1;
        INP_VALID = 2'b01;
        apply_test(8'd5,  8'd0, 4'd5, "DEC_A(dec_a_normal)");
        apply_test(8'd0,  8'd0, 4'd5, "DEC_A(dec_a_out_of_range)");
        INP_VALID = 2'b10;
        apply_test(8'd10, 8'd0, 4'd5, "DEC_A(dec_a_invalid)");
	INP_VALID = 2'b11;
        apply_test(8'd5,  8'd0, 4'd5, "DEC_A(dec_a_normal)");

//INC B
        $display("\n INC_B TESTS ");
        MODE = 1;
        INP_VALID = 2'b10;
        apply_test(8'd0, 8'd11,  4'd6, "INC_B(inc_b_normal)");
        apply_test(8'd0, 8'd255, 4'd6, "INC_B(inc_b_out_of_range)");
        INP_VALID = 2'b01;
        apply_test(8'd0, 8'd5,   4'd6, "INC_B(inc_b_invalid)");
	INP_VALID = 2'b11;
	apply_test(8'd0, 8'd255, 4'd6, "INC_B(inc_b_out_of_range)");

//DEC B
        $display("\n DEC_B TESTS ");
        MODE = 1;
        INP_VALID = 2'b10;
        apply_test(8'd0, 8'd12, 4'd7, "DEC_B(dec_b_normal)");
        apply_test(8'd0, 8'd0,  4'd7, "DEC_B(dec_b_out_of_range)");
        INP_VALID = 2'b01;
        apply_test(8'd0, 8'd10, 4'd7, "DEC_B(dec_b_invalid)");
	INP_VALID = 2'b11;
	apply_test(8'd0, 8'd12, 4'd7, "DEC_B(dec_b_normal)");

//CMP
        $display("\n CMP TESTS ");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd50,  8'd30, 4'd8, "CMP(cmp_opa_gt_opb)");
        apply_test(8'd20,  8'd30, 4'd8, "CMP(cmp_opa_lt_opb)");
        apply_test(8'd20,  8'd20, 4'd8, "CMP(cmp_opa_eq_opb)");
        apply_test(8'd255, 8'd0,  4'd8, "CMP(cmp_max)");
        apply_test(8'd0,   8'd0,  4'd8, "CMP(cmp_zero_zero)");
        INP_VALID = 2'b01;
        apply_test(8'd30,  8'd20, 4'd8, "CMP(cmp_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'd30,  8'd20, 4'd8, "CMP(cmp_invalid)");


//INC AND MUL
        $display("\n INC_MUL TESTS");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd3,   8'd3,   4'd9, "INC_MUL(inc_mul_normal_1)");
        apply_test(8'd5,   8'd3,   4'd9, "INC_MUL(inc_mul_normal_2)");
        apply_test(8'd3,   8'd5,   4'd9, "INC_MUL(inc_mul_normal_3)");
        apply_test(8'd0,   8'd0,   4'd9, "INC_MUL(inc_mul_zero_operands)");
        apply_test(8'd255, 8'd255, 4'd9, "INC_MUL(inc_mul_max_operands)");
        apply_test(8'd3,   8'd4,   4'd9, "INC_MUL(inc_mul_exact_check)");
	MODE = 1; INP_VALID = 2'b01;
        apply_test(8'd3,   8'd3,   4'd9, "INC_MUL(inc_mul_invalid)");
	MODE = 1; INP_VALID = 2'b10;
        apply_test(8'd3,   8'd3,   4'd9, "INC_MUL(inc_mul_invalid)");



//SHIFT AND MUL
        $display("\n SHIFT_MUL TESTS ");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd4,   8'd4,   4'd10, "SHIFT_MUL(shift_mul_equal)");
        apply_test(8'd4,   8'd2,   4'd10, "SHIFT_MUL(shift_mul_greater)");
        apply_test(8'd2,   8'd4,   4'd10, "SHIFT_MUL(shift_mul_lesser)");
        apply_test(8'd2,   8'd2,   4'd10, "SHIFT_MUL(shift_mul_invalid)");
        INP_VALID = 2'b11;
        apply_test(8'd0,   8'd5,   4'd10, "SHIFT_MUL(cmd10_zero_shift)");
        apply_test(8'd255, 8'd255, 4'd10, "SHIFT_MUL(cmd10_max_operands)");
	MODE = 1; INP_VALID = 2'b01;
        apply_test(8'd4,   8'd4,   4'd10, "SHIFT_MUL(shift_mul_invalid)");
	MODE = 1; INP_VALID = 2'b10;
        apply_test(8'd4,   8'd4,   4'd10, "SHIFT_MUL(shift_mul_invalid)");


//SIGNED ADD
        $display("\n SIGNED_ADD TESTS");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd20,  8'd30,  4'd11, "SIGNED_ADD(signed_add_pos)");
        apply_test(8'd127, 8'd127, 4'd11, "SIGNED_ADD(signed_add_all_bits)");
        apply_test(8'd127, 8'd1,   4'd11, "SIGNED_ADD(signed_add_oflow)");
        apply_test(8'h80,  8'h80,  4'd11, "SIGNED_ADD(signed_add_neg_plus_neg)");
        apply_test(8'd0,   8'd0,   4'd11, "SIGNED_ADD(signed_add_zero)");
	INP_VALID = 2'b10;
        apply_test(8'd20,  8'd30,  4'd11, "SIGNED_ADD(signed_add_invalid)");
	INP_VALID = 2'b01;
        apply_test(8'd20,  8'd30,  4'd11, "SIGNED_ADD(signed_add_invalid)");


//SIGNED SUB
        $display("\n SIGNED_SUB TESTS ");
        MODE = 1; INP_VALID = 2'b11;
        apply_test(8'd50,  8'd30,  4'd12, "SIGNED_SUB(signed_sub_normal)");
        apply_test(8'd128, 8'd1,   4'd12, "SIGNED_SUB(signed_sub_oflow)");
	apply_test(8'd2, 8'd7,   4'd12, "SIGNED_SUB(signed_sub_oflow)");
        apply_test(8'h80,  8'h01,  4'd12, "SIGNED_SUB(signed_sub_neg_minus_pos)");
        apply_test(8'h7F,  8'hFF,  4'd12, "SIGNED_SUB(signed_sub_pos_minus_neg)");
        apply_test(8'd20,  8'd20,  4'd12, "SIGNED_SUB(signed_sub_equal)");
        apply_test(8'h90,  8'h50,  4'd12, "SIGNED_SUB(signed_cmp_negative_vals)");
        INP_VALID = 2'b01;
        apply_test(8'd1,   8'd1,   4'd12, "SIGNED_SUB(signed_sub_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'd1,   8'd1,   4'd12, "SIGNED_SUB(signed_sub_invalid)");
	

//AND
        $display("\n AND TESTS");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'd2,  8'd3,  4'd0, "AND(and_normal)");
        apply_test(8'h00, 8'h00, 4'd0, "AND(and_zeros)");
        apply_test(8'hFF, 8'hFF, 4'd0, "AND(and_ones)");
        INP_VALID = 2'b10;
        apply_test(8'd4,  8'd5,  4'd0, "AND(and_invalid)");
	INP_VALID = 2'b01;
        apply_test(8'd4,  8'd5,  4'd0, "AND(and_invalid)");

 
        // NAND
        $display("\nNAND TESTS");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'hAA, 8'hCC, 4'd1, "NAND(nand_normal)");
        apply_test(8'h00, 8'h00, 4'd1, "NAND(nand_zeros)");
        apply_test(8'hFF, 8'hFF, 4'd1, "NAND(nand_ones)");
        INP_VALID = 2'b01;
        apply_test(8'd10, 8'd5,  4'd1, "NAND(nand_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'd10, 8'd5,  4'd1, "NAND(nand_invalid)");


//OR
        $display("\nOR TESTS");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'd2,  8'd3,  4'd2, "OR(or_normal)");
        apply_test(8'h00, 8'h00, 4'd2, "OR(or_zeros)");
        apply_test(8'hFF, 8'hFF, 4'd2, "OR(or_ones)");
        INP_VALID = 2'b10;
        apply_test(8'd3,  8'd6,  4'd2, "OR(or_invalid)");
	INP_VALID = 2'b01;
        apply_test(8'd3,  8'd6,  4'd2, "OR(or_invalid)");



        // NOR (ID 88-91)

        $display("\n NOR TESTS");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'd25, 8'd15, 4'd3, "NOR(nor_normal)");
        apply_test(8'h00, 8'h00, 4'd3, "NOR(nor_zeros)");
        apply_test(8'hFF, 8'hFF, 4'd3, "NOR(nor_ones)");
        INP_VALID = 2'b01;
        apply_test(8'd1,  8'd2,  4'd3, "NOR(nor_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'd1,  8'd2,  4'd3, "NOR(nor_invalid)");

        // XOR

        $display("\n XOR TESTS ");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'd3,  8'd5,  4'd4, "XOR(xor_normal)");
        apply_test(8'h00, 8'h00, 4'd4, "XOR(xor_zeros)");
        apply_test(8'hFF, 8'hFF, 4'd4, "XOR(xor_ones)");
        INP_VALID = 2'b01;
        apply_test(8'd3,  8'd5,  4'd4, "XOR(xor_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'd3,  8'd5,  4'd4, "XOR(xor_invalid)");


 
        // XNOR

        $display("\n XNOR TESTS");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'd23, 8'd19, 4'd5, "XNOR(xnor_normal)");
        apply_test(8'h00, 8'h00, 4'd5, "XNOR(xnor_zeros)");
        apply_test(8'hFF, 8'hFF, 4'd5, "XNOR(xnor_ones)");
        INP_VALID = 2'b10;
        apply_test(8'd5,  8'd7,  4'd5, "XNOR(xnor_invalid)");
	INP_VALID = 2'b01;
        apply_test(8'd5,  8'd7,  4'd5, "XNOR(xnor_invalid)");


 
        // NOT_A
 
        $display("\n NOT_A TESTS ");
        MODE = 0; INP_VALID = 2'b01;
        apply_test(8'd220, 8'h00, 4'd6, "NOT_A(not_a_normal)");
        apply_test(8'h00,  8'h00, 4'd6, "NOT_A(not_a_zeros)");
        apply_test(8'hFF,  8'h00, 4'd6, "NOT_A(not_a_ones)");
        INP_VALID = 2'b11;
        apply_test(8'd20,  8'd0,  4'd6, "NOT_A(not_a_normal)");
	INP_VALID = 2'b10;
        apply_test(8'd20,  8'd0,  4'd6, "NOT_A(not_a_invalid)");


        // NOT_B
        $display("\n NOT_B TESTS ");
        MODE = 0; INP_VALID = 2'b10;
        apply_test(8'h00, 8'd100, 4'd7, "NOT_B(not_b_normal)");
	MODE = 0; INP_VALID = 2'b10;
        apply_test(8'h00, 8'd100, 4'd7, "NOT_B(not_b_normal)");
        apply_test(8'h00, 8'h00,  4'd7, "NOT_B(not_b_zeros)");
        apply_test(8'h00, 8'hFF,  4'd7, "NOT_B(not_b_ones)");
        INP_VALID = 2'b01;
        apply_test(8'd0,  8'd7,   4'd7, "NOT_B(not_b_invalid)");


        // SHIFT_RIGHT_A
        $display("\n SHR1_A TESTS");
        MODE = 0; INP_VALID = 2'b01;
        apply_test(8'hAA, 8'h00, 4'd8, "SHR1_A(shift_right_a_normal)");
	MODE = 0; INP_VALID = 2'b11;
        apply_test(8'hAA, 8'h00, 4'd8, "SHR1_A(shift_right_a_normal)");
        apply_test(8'h01, 8'h00, 4'd8, "SHR1_A(shift_right_a_one_bit)");
        apply_test(8'h80, 8'h00, 4'd8, "SHR1_A(shr_a_msb_one)");
        INP_VALID = 2'b10;
        apply_test(8'd3,  8'h00, 4'd8, "SHR1_A(shift_right_a_invalid)");


        // SHIFT_LEFT_A
 
        $display("\n SHL1_A TESTS ");
        MODE = 0; INP_VALID = 2'b01;
        apply_test(8'd4,  8'h00, 4'd9, "SHL1_A(shift_left_a_normal)");
	MODE = 0; INP_VALID = 2'b10;
        apply_test(8'd4,  8'h00, 4'd9, "SHL1_A(shift_left_a_normal)");
        apply_test(8'h80, 8'h00, 4'd9, "SHL1_A(shl_a_msb_loss)");
        apply_test(8'h80, 8'h00, 4'd9, "SHL1_A(shift_left_a_one_bit)");
        INP_VALID = 2'b10;
        apply_test(8'd5,  8'h00, 4'd9, "SHL1_A(shift_left_a_invalid)");

        // SHIFT_RIGHT_B
 
        $display("\n SHR1_B TESTS ");
        MODE = 0; INP_VALID = 2'b10;
        apply_test(8'h00, 8'hAA, 4'd10, "SHR1_B(shift_right_b_normal)");
	MODE = 0; INP_VALID = 2'b01;
        apply_test(8'h00, 8'hAA, 4'd10, "SHR1_B(shift_right_b_normal)");
        apply_test(8'h00, 8'h01, 4'd10, "SHR1_B(shift_right_b_one_bit)");
        apply_test(8'h00, 8'h01, 4'd10, "SHR1_B(shr_b_lsb_one)");
        INP_VALID = 2'b01;
        apply_test(8'h00, 8'd3,  4'd10, "SHR1_B(shift_right_b_invalid)");

 
        // SHIFT_LEFT_B
 
        $display("\n SHL1_B TESTS ");
        MODE = 0; INP_VALID = 2'b10;
        apply_test(8'h00, 8'd4,  4'd11, "SHL1_B(shift_left_b_normal)");
	MODE = 0; INP_VALID = 2'b11;
        apply_test(8'h00, 8'd4,  4'd11, "SHL1_B(shift_left_b_normal)");
        apply_test(8'h00, 8'h80, 4'd11, "SHL1_B(shift_left_b_one_bit)");
        apply_test(8'h00, 8'h01, 4'd11, "SHL1_B(shl_b_lsb_set)");
        INP_VALID = 2'b01;
        apply_test(8'h00, 8'd5,  4'd11, "SHL1_B(shift_left_b_invalid)");

        // ROTATE_LEFT
        $display("\n ROL_A_B TESTS ");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'hA5, 8'h02, 4'd12, "ROL_A_B(rotate_a_left_normal)");
        apply_test(8'hA5, 8'h00, 4'd12, "ROL_A_B(rotate_a_left_zero)");
        apply_test(8'h80, 8'h01, 4'd12, "ROL_A_B(rotate_left_by_1)");
        apply_test(8'h01, 8'h07, 4'd12, "ROL_A_B(rotate_left_by_7)");
        apply_test(8'hAA, 8'h08, 4'd12, "ROL_A_B(rotate_left_opb_upper_bits)");
        apply_test(8'hAA, 8'hFF, 4'd12, "ROL_A_B(rotate_left_opb_large)");
        apply_test(8'h87, 8'hDC, 4'd12, "ROL_A_B(rotate_a_left_upper_bits_err)");
        INP_VALID = 2'b01;
        apply_test(8'h03, 8'h02, 4'd12, "ROL_A_B(rotate_a_left_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'h03, 8'h02, 4'd12, "ROL_A_B(rotate_a_left_invalid)");


        // ROTATE_RIGHT
        $display("\n ROR_A_B TESTS");
        MODE = 0; INP_VALID = 2'b11;
        apply_test(8'h14, 8'h02, 4'd13, "ROR_A_B(rotate_a_right_normal)");
        apply_test(8'h14, 8'h00, 4'd13, "ROR_A_B(rotate_a_right_zero)");
        apply_test(8'h01, 8'h01, 4'd13, "ROR_A_B(rotate_right_by_1)");
        apply_test(8'h80, 8'h07, 4'd13, "ROR_A_B(rotate_right_by_7)");
        apply_test(8'hAA, 8'h08, 4'd13, "ROR_A_B(rotate_right_opb_upper_bits)");
        apply_test(8'h23, 8'h91, 4'd13, "ROR_A_B(rotate_a_right_err)");
        INP_VALID = 2'b01;
        apply_test(8'h03, 8'h02, 4'd13, "ROR_A_B(rotate_a_right_invalid)");
	INP_VALID = 2'b10;
        apply_test(8'h03, 8'h02, 4'd13, "ROR_A_B(rotate_a_right_invalid)");

 
        // SUMMARY
        $display("\n");
        $display("TOTAL TESTS = %0d", test_count);
        $display("PASS TESTS  = %0d", pass_count);
        $display("FAIL TESTS  = %0d", fail_count);
        $display("  \n");

        #10000; $finish;
    end

	task apply_test(
    input [7:0]     a,
    input [7:0]     b,
    input [3:0]     cmd,
    input [200*8:1] test_name
);

begin

    // Apply BEFORE clock edge
    OPA = a;
    OPB = b;
    CMD = cmd;

    // NORMAL OPS -> registered output after 1 clock
    if(cmd != 4'd9 && cmd != 4'd10) begin

        @(posedge CLK);

    end

    // MUL OPS -> pipeline latency
    else begin

        @(posedge CLK);   // capture temp regs
        @(posedge CLK);   // multiply executes
        @(posedge CLK);   // output stable

    end

    #1;

    test_count = test_count + 1;

    if(compare_outputs(1'b0)) begin

        pass_count = pass_count + 1;

        $display("[PASS] %-30s | OPA=%0d OPB=%0d CMD=%0d MODE=%0d INP_VALID=%0b | RES=%0d",
                 test_name, a, b, cmd, MODE, INP_VALID, RES_dut);

    end
    else begin

        fail_count = fail_count + 1;

        $display("[FAIL] %-30s", test_name);

        $display(" DUT : RES=%0d COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                 RES_dut, COUT_dut, OFLOW_dut,
                 G_dut, E_dut, L_dut, ERR_dut);

        $display(" REF : RES=%0d COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                 RES_ref, COUT_ref, OFLOW_ref,
                 G_ref, E_ref, L_ref, ERR_ref);

    end

end
endtask

    function compare_outputs;
        input dummy;
    begin
        compare_outputs = 1'b1;
        if (RES_dut   !== RES_ref)   compare_outputs = 1'b0;
        if (COUT_dut  !== COUT_ref)  compare_outputs = 1'b0;
        if (OFLOW_dut !== OFLOW_ref) compare_outputs = 1'b0;
        if (G_dut     !== G_ref)     compare_outputs = 1'b0;
        if (E_dut     !== E_ref)     compare_outputs = 1'b0;
        if (L_dut     !== L_ref)     compare_outputs = 1'b0;
        if (ERR_dut   !== ERR_ref)   compare_outputs = 1'b0;
    end
    endfunction

    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end

endmodule
