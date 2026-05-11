`timescale 1ns/1ps

module alu_reference_model(
    input  [7:0] OPA,
    input  [7:0] OPB,
    input        CIN,
    input        MODE,
    input  [3:0] CMD,
    input  [1:0] INP_VALID,

    output reg [15:0] RES,
    output reg COUT,
    output reg OFLOW,
    output reg G,
    output reg E,
    output reg L,
    output reg ERR
);

always @(*) begin

   
    RES   = 16'b0;
    COUT  = 1'b0;
    OFLOW = 1'b0;
    G     = 1'b0;
    E     = 1'b0;
    L     = 1'b0;
    ERR   = 1'b0;


    // ARITHMETIC MODE
    if (MODE) begin

        case (CMD)

            // ADD
            4'b0000: begin
                if (INP_VALID == 2'b11) begin
                    RES   = OPA + OPB;
                    COUT  = RES[8];
                    OFLOW = (~OPA[7] & ~OPB[7] & RES[7]) |
                            ( OPA[7] &  OPB[7] & ~RES[7]);
                end else begin
                    ERR = 1'b1;
                end
            end

            // SUB
            4'b0001: begin
                if (INP_VALID == 2'b11) begin
                    RES   = OPA - OPB;
                    OFLOW = (OPA < OPB);
                end else begin
                    ERR = 1'b1;
                end
            end

            // ADD_CIN
            4'b0010: begin
                if (INP_VALID == 2'b11) begin
                    RES   = OPA + OPB + CIN;
                    COUT  = RES[8];
                    OFLOW = (~OPA[7] & ~OPB[7] & RES[7]) |
                            ( OPA[7] &  OPB[7] & ~RES[7]);
                end else begin
                    ERR = 1'b1;
                end
            end

            // SUB_CIN
            4'b0011: begin
                if (INP_VALID == 2'b11) begin
                    RES   = OPA - OPB - CIN;
                    OFLOW = (OPA < (OPB + CIN));
                end else begin
                    ERR = 1'b1;
                end
            end

            // INC_A
            4'b0100: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b01) begin
                    RES = OPA + 1;
                    // COUT stays 0 for INC_A
                end else begin
                    ERR = 1'b1;
                end
            end

            // DEC_A
            4'b0101: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b01) begin
                    RES = OPA - 1;
                end else begin
                    ERR = 1'b1;
                end
            end

            // INC_B
            4'b0110: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b10) begin
                    RES = OPB + 1;
                end else begin
                    ERR = 1'b1;
                end
            end

            // DEC_B
            4'b0111: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b10) begin
                    RES   = OPB - 1;
                    OFLOW = (OPB == 8'b0);
                end else begin
                    ERR = 1'b1;
                end
            end

            // CMP
            4'b1000: begin
                if (INP_VALID == 2'b11) begin
                    RES = 16'b0;
                    G   = (OPA > OPB);
                    E   = (OPA == OPB);
                    L   = (OPA < OPB);
                end else begin
                    ERR = 1'b1;
                end
            end

            // INC_MUL
            4'b1001: begin
                if (INP_VALID == 2'b11) begin
                    RES = (OPA + 1) * (OPB + 1);
                end else begin
                    ERR = 1'b1;
                end
            end

            // SHIFT_MUL
            4'b1010: begin
                if (INP_VALID == 2'b11) begin
                    RES = (OPA << 1) * OPB;
                end else begin
                    ERR = 1'b1;
                end
            end

            // SIGNED_ADD
            4'b1011: begin
                if (INP_VALID == 2'b11) begin
                    RES   = $signed(OPA) + $signed(OPB);
                    OFLOW = (~OPA[7] & ~OPB[7] & RES[7]) |
                            ( OPA[7] &  OPB[7] & ~RES[7]);
                    G = ($signed(OPA) > $signed(OPB));
                    E = ($signed(OPA) == $signed(OPB));
                    L = ($signed(OPA) < $signed(OPB));
                end else begin
                    ERR = 1'b1;
                end
            end

            // SIGNED_SUB
            4'b1100: begin
                if (INP_VALID == 2'b11) begin
                    RES   = $signed(OPA) - $signed(OPB);
                    OFLOW = (~OPA[7] &  OPB[7] & RES[7]) |
                            ( OPA[7] & ~OPB[7] & ~RES[7]);
                    G = ($signed(OPA) > $signed(OPB));
                    E = ($signed(OPA) == $signed(OPB));
                    L = ($signed(OPA) < $signed(OPB));
                end else begin
                    ERR = 1'b1;
                end
            end

            default: begin
                ERR = 1'b1;
                RES = 16'b0;
            end

        endcase

    end

//LOGICAL
    else begin

        case (CMD)

            // AND
            4'b0000: begin
                if (INP_VALID == 2'b11) begin
                    RES = {8'b0, (OPA & OPB)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // NAND
            4'b0001: begin
                if (INP_VALID == 2'b11) begin
                    RES = {8'b0, ~(OPA & OPB)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // OR
            4'b0010: begin
                if (INP_VALID == 2'b11) begin
                    RES = {8'b0, (OPA | OPB)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // NOR
            4'b0011: begin
                if (INP_VALID == 2'b11) begin
                    RES = {8'b0, ~(OPA | OPB)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // XOR
            4'b0100: begin
                if (INP_VALID == 2'b11) begin
                    RES = {8'b0, (OPA ^ OPB)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // XNOR
            4'b0101: begin
                if (INP_VALID == 2'b11) begin
                    RES = {8'b0, ~(OPA ^ OPB)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // NOT_A
            4'b0110: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b01) begin
                    RES = {8'b0, ~OPA};
                end else begin
                    ERR = 1'b1;
                end
            end

            // NOT_B
            4'b0111: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b10) begin
                    RES = {8'b0, ~OPB};
                end else begin
                    ERR = 1'b1;
                end
            end

            // SHR1_A
            4'b1000: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b01) begin
                    RES = {8'b0, (OPA >> 1)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // SHL1_A
            4'b1001: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b01) begin
                    RES = {8'b0, (OPA << 1)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // SHR1_B
            4'b1010: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b10) begin
                    RES = {8'b0, (OPB >> 1)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // SHL1_B
            4'b1011: begin
                if (INP_VALID == 2'b11 || INP_VALID == 2'b10) begin
                    RES = {8'b0, (OPB << 1)};
                end else begin
                    ERR = 1'b1;
                end
            end

            // ROL_A_B
            4'b1100: begin
                if (INP_VALID == 2'b11) begin
                    if (OPB > 8'd7) begin
                        ERR = 1'b1;
                        RES = 16'b0;
                    end else begin
                        RES = {8'b0, ((OPA << OPB[2:0]) | (OPA >> (8 - OPB[2:0])))};
                    end
                end else begin
                    ERR = 1'b1;
                end
            end

            // ROR_A_B
            4'b1101: begin
                if (INP_VALID == 2'b11) begin
                    if (OPB > 8'd7) begin
                        ERR = 1'b1;
                        RES = 16'b0;
                    end else begin
                        RES = {8'b0, ((OPA >> OPB[2:0]) | (OPA << (8 - OPB[2:0])))};
                    end
                end else begin
                    ERR = 1'b1;
                end
            end

            default: begin
                ERR = 1'b1;
                RES = 16'b0;
            end

        endcase

    end

end

endmodule
