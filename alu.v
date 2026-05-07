`default_nettype none

module alu2(clk,rst,inp_valid,mode,cmd,ce,opA,opB,cin,err,res,oflow,cout,G,L,E);

parameter DW=8;
parameter C=4;

input wire clk,rst,mode,ce,cin;
input wire [1:0] inp_valid;
input wire [DW-1:0] opA,opB;
input wire [C-1:0] cmd;

output reg err,oflow,cout,G,L,E;
output reg [DW*2-1:0] res;

reg [DW*2-1:0] next_res;
reg next_err,next_oflow,next_cout,next_G,next_L,next_E;

reg [1:0] tmpcnt9,tmpcnt10;
reg [DW-1:0] tmpA9,tmpB9;
reg [DW-1:0] tmpA10,tmpB10;
reg [DW*2-1:0] tmpres9,tmpres10;
reg v9,v10;

reg signed [DW-1:0] s_A,s_B;
reg signed [DW:0] s_res;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        res <= 0;
        cout <= 0;
        G <= 0;
        L <= 0;
        E <= 0;
        err <= 0;
        oflow <= 0;

        next_res <= 0;
        next_err <= 0;
        next_oflow <= 0;
        next_cout <= 0;
        next_G <= 0;
        next_L <= 0;
        next_E <= 0;

        tmpcnt9 <= 0;
        tmpcnt10 <= 0;

        tmpA9 <= 0;
        tmpB9 <= 0;

        tmpA10 <= 0;
        tmpB10 <= 0;

        tmpres9 <= 0;
        tmpres10 <= 0;

        v9 <= 0;
        v10 <= 0;
    end

    else if(ce)
    begin
        res <= next_res;
        err <= next_err;
        oflow <= next_oflow;
        cout <= next_cout;
        G <= next_G;
        L <= next_L;
        E <= next_E;

        next_res <= res;
        next_err <= 0;
        next_oflow <= 0;
        next_cout <= 0;
        next_G <= 0;
        next_L <= 0;
        next_E <= 0;

        case(mode)

        1'b1:
        begin
            case(cmd)

            4'd0:
            begin
                if(inp_valid==2'b11)
                    {next_cout,next_res[DW-1:0]} <= opA + opB;
                else
                    next_err <= 1;
            end

            4'd1:
            begin
                if(inp_valid==2'b11)
                begin
                    if(opA<opB)
                        next_oflow <= 1;
                    else
                        next_res <= opA-opB;
                end
                else
                    next_err <= 1;
            end

            4'd2:
            begin
                if(inp_valid==2'b11)
                    {next_cout,next_res[DW-1:0]} <= opA + opB + cin;
                else
                    next_err <= 1;
            end

            4'd3:
            begin
                if(inp_valid==2'b11)
                begin
                    if(opA<opB)
                        next_err <= 1;
                    else
                        next_res <= opA-opB-cin;
                end
                else
                    next_err <= 1;
            end

            4'd4:
            begin
                if(inp_valid==2'b01 || inp_valid==2'b11)
                    next_res <= opA + 1;
                else
                    next_err <= 1;
            end

            4'd5:
            begin
                if(inp_valid==2'b01 || inp_valid==2'b11)
                    next_res <= opA - 1;
                else
                    next_err <= 1;
            end

            4'd6:
            begin
                if(inp_valid==2'b10 || inp_valid==2'b11)
                    next_res <= opB + 1;
                else
                    next_err <= 1;
            end

            4'd7:
            begin
                if(inp_valid==2'b10 || inp_valid==2'b11)
                    next_res <= opB - 1;
                else
                    next_err <= 1;
            end

            4'd8:
            begin
                if(inp_valid==2'b11)
                begin
                    if(opA>opB)
                        next_G <= 1;
                    else if(opA<opB)
                        next_L <= 1;
                    else
                        next_E <= 1;
                end
                else
                    next_err <= 1;
            end

            4'd9:
            begin
                if(inp_valid==2'b11)
                begin
                    tmpA9 <= opA + 1;
                    tmpB9 <= opB + 1;
                    tmpcnt9 <= 1;
                    v9 <= 1;
                end

                if(v9)
                begin
                    if(tmpcnt9==1)
                    begin
                        tmpres9 <= tmpA9 * tmpB9;
                        tmpcnt9 <= 2;
                    end
                    else if(tmpcnt9==2)
                    begin
                        next_res <= tmpres9;
                        tmpcnt9 <= 0;
                        v9 <= 0;
                    end
                end
            end

            4'd10:
            begin
                if(inp_valid==2'b11)
                begin
                    tmpA10 <= opA << 1;
                    tmpB10 <= opB;
                    tmpcnt10 <= 1;
                    v10 <= 1;
                end

                if(v10)
                begin
                    if(tmpcnt10==1)
                    begin
                        tmpres10 <= tmpA10 * tmpB10;
                        tmpcnt10 <= 2;
                    end
                    else if(tmpcnt10==2)
                    begin
                        next_res <= tmpres10;
                        tmpcnt10 <= 0;
                        v10 <= 0;
                    end
                end
            end

            4'd11:
            begin
                if(inp_valid==2'b11)
                begin
                    s_A = $signed(opA);
                    s_B = $signed(opB);
                    s_res = s_A + s_B;

                    next_res <= {{(DW-1){1'b0}},s_res};

                    next_oflow <= (~opA[DW-1] & ~opB[DW-1] & s_res[DW-1]) |
                                   ( opA[DW-1] &  opB[DW-1] & ~s_res[DW-1]);

                    if(s_A>s_B)
                        next_G <= 1;
                    else if(s_A<s_B)
                        next_L <= 1;
                    else
                        next_E <= 1;
                end
                else
                    next_err <= 1;
            end

            4'd12:
            begin
                if(inp_valid==2'b11)
                begin
                    s_A = $signed(opA);
                    s_B = $signed(opB);
                    s_res = s_A - s_B;

                    next_res <= {{(DW-1){1'b0}},s_res};

                    next_oflow <= (~opA[DW-1] & opB[DW-1] & s_res[DW-1]) |
                                   ( opA[DW-1] & ~opB[DW-1] & ~s_res[DW-1]);

                    if(s_A>s_B)
                        next_G <= 1;
                    else if(s_A<s_B)
                        next_L <= 1;
                    else
                        next_E <= 1;
                end
                else
                    next_err <= 1;
            end

            default:
            begin
                next_res <= 0;
                next_cout <= 0;
            end

            endcase
        end

        1'b0:
        begin
            case(cmd)

            4'd0:  if(inp_valid==2'b11) next_res <= {8'b0,(opA & opB)}; else next_err <= 1;
            4'd1:  if(inp_valid==2'b11) next_res <= {8'b0,~(opA & opB)}; else next_err <= 1;
            4'd2:  if(inp_valid==2'b11) next_res <= {8'b0,(opA | opB)}; else next_err <= 1;
            4'd3:  if(inp_valid==2'b11) next_res <= {8'b0,~(opA | opB)}; else next_err <= 1;
            4'd4:  if(inp_valid==2'b11) next_res <= {8'b0,(opA ^ opB)}; else next_err <= 1;
            4'd5:  if(inp_valid==2'b11) next_res <= {8'b0,~(opA ^ opB)}; else next_err <= 1;
            4'd6:  if(inp_valid==2'b01 || inp_valid==2'b11) next_res <= {8'b0,(~opA)}; else next_err <= 1;
            4'd7:  if(inp_valid==2'b10 || inp_valid==2'b11) next_res <= {8'b0,(~opB)}; else next_err <= 1;
            4'd8:  if(inp_valid==2'b01 || inp_valid==2'b11) next_res <= {8'b0,(opA >> 1)}; else next_err <= 1;
            4'd9:  if(inp_valid==2'b01 || inp_valid==2'b11) next_res <= {8'b0,(opA << 1)}; else next_err <= 1;
            4'd10: if(inp_valid==2'b10 || inp_valid==2'b11) next_res <= {8'b0,(opB >> 1)}; else next_err <= 1;
            4'd11: if(inp_valid==2'b10 || inp_valid==2'b11) next_res <= {8'b0,(opB << 1)}; else next_err <= 1;

            4'd12:
            begin
                if(inp_valid==2'b11)
                    next_res <= {8'b0,((opA << opB[2:0]) | (opA >> (DW-opB[2:0])))};
                else
                    next_err <= 1;
            end

            4'd13:
            begin
                if(inp_valid==2'b11)
                    next_res <= {8'b0,((opA >> opB[2:0]) | (opA << (DW-opB[2:0])))};
                else
                    next_err <= 1;
            end

            default:
            begin
                next_res <= 0;
                next_cout <= 0;
            end

            endcase
        end

        endcase
    end
end

endmodule
