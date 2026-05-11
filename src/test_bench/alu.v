module alu#(parameter WIDTH=8,parameter CMD_WIDTH = 4)(CLK,RST,INP_VALID,MODE,CMD,CE,OPA,OPB,CIN,ERR,RES,OFLOW,COUT,G,L,E);
input wire CLK,RST,CIN,CE,MODE;
input wire [1:0] INP_VALID;
input wire [WIDTH-1:0] OPA,OPB;
input wire [CMD_WIDTH-1:0] CMD;
output reg [WIDTH*2-1:0]RES;
output reg ERR;
output reg OFLOW;
output reg COUT;
output reg G,L,E;

reg [WIDTH-1:0] temp_a, temp_b;
reg [(WIDTH*2)-1:0] mul;
reg [1:0] mul_state;
reg mul_err;

always@(posedge CLK or posedge RST) begin
    if(RST) begin
        ERR<=1'b0;
        OFLOW<=1'b0;
        COUT<=1'b0;
        G<=1'b0;
        L<=1'b0;
        E<=1'b0;
        mul_state<=2'b00;
        mul_err<=1'b0;
        RES<={WIDTH*2{1'b0}};
    end
    else if(CE) begin
        if (mul_state == 2'd1) begin
            mul <= temp_a * temp_b; // Cycle 2: Execute 
            mul_state <= 2'd2;
        end
        else if (mul_state == 2'd2) begin
            mul_state <= 2'd0;      // Cycle 3: Free the pipeline
        end
        if(MODE) begin
            ERR<=1'b0;
            OFLOW<=1'b0;
            COUT<=1'b0;
            G<=1'b0;
            L<=1'b0;
            E<=1'b0;
            RES<={WIDTH*2{1'b0}};
            if (CMD != 4'b1001 && CMD != 4'b1010) begin
              mul_err <= 1'b0; 
            end
             case(CMD)
                4'b0000:begin            //ADD
                    if(INP_VALID==2'b11) begin
                        RES  <= OPA + OPB;
                        COUT <= ({1'b0, OPA} + {1'b0, OPB}) >> WIDTH;
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0001:begin          //SUB
                    if(INP_VALID==2'b11) begin
                        RES<=OPA-OPB;
                        OFLOW<=(OPA<OPB)?1:0;  //Acts like borrow flag
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0010:begin           //ADD_CIN
                    if(INP_VALID==2'b11) begin
                        RES  <= OPA + OPB + CIN;
                        COUT <= ({1'b0, OPA} + {1'b0, OPB} + CIN) >> WIDTH;
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin 
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0011:begin         //SUB_CIN
                    if(INP_VALID==2'b11) begin
                        OFLOW <= (OPA < OPB) | ((OPA == OPB) & CIN); //acts like borrow flag
                        RES<=OPA-OPB-CIN;
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0100:begin         //INC_A
                    if(INP_VALID==2'b11) begin
                        RES  <= OPA + 1;
                        COUT <= ({1'b0, OPA} + 1) >> WIDTH;
                    end
                    else if(INP_VALID==2'b01) begin
                        RES  <= OPA + 1;
                        COUT <= ({1'b0, OPA} + 1) >> WIDTH;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0101:begin           //DEC_A
                    if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
                        RES  <= OPA - 1;
                      COUT <= (OPA == {WIDTH{1'b0}}) ? 1'b1 : 1'b0; //Underflow
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0110:begin            //INC_B
                    if(INP_VALID==2'b11) begin
                       RES  <= OPB + 1;
                       COUT <= ({1'b0, OPB} + 1) >> WIDTH;
                    end
                    else if(INP_VALID==2'b01) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin
                       RES  <= OPB + 1;
                       COUT <= ({1'b0, OPB} + 1) >> WIDTH;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0111:begin                  //DEC_B
                    if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
                        RES  <= OPB - 1;
                        COUT <= (OPB == {WIDTH{1'b0}}) ? 1'b1 : 1'b0; 
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b1000:begin              //COMP
                    if(INP_VALID==2'b11) begin
                        ERR<=1'b0;
                        OFLOW<=1'b0;
                        COUT<=1'b0;
                        G<=1'b0;
                        L<=1'b0;
                        E<=1'b0;
                        RES<={(WIDTH*2){1'b0}};
                        if(OPA==OPB)begin
                            G<=1'b0;
                            E<=1'b1;
                            L<=1'b0;
                        end
                        else if(OPA>OPB)begin
                            G<=1'b1;
                            E<=1'b0;
                            L<=1'b0;
                        end
                        else begin
                            G<=1'b0;
                            E<=1'b0;
                            L<=1'b1;
                        end
                    end
                    else if(INP_VALID==2'b01 || INP_VALID==2'b10) begin
                        ERR<=1'b1;
                        OFLOW<=1'b0;
                        COUT<=1'b0;
                        G<=1'b0;
                        L<=1'b0;
                        E<=1'b0;
                        RES<={WIDTH*2{1'b0}};
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b1001:begin      // Increment and Multiply
                    if(INP_VALID==2'b11) begin
                    mul_err<=1'b0;
                        if (mul_state == 2'd0) begin 
                            temp_a <= OPA + 1;
                            temp_b <= OPB + 1;
                            mul_state <= 2'd1; // Trigger Cycle 1
                        end
                        RES <= {(WIDTH*2){1'b0}};
                        ERR<=1'b0;
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        mul_err<=1'b1;
                        ERR<=mul_err;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        mul_err<=1'b1;
                        ERR<=mul_err;
                    end
                    else begin
                        mul_err<=1'b1;
                        ERR<=mul_err;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b1010:begin             //Left Shift A by 1 and Multiply
                    if(INP_VALID==2'b11) begin
                    mul_err<=1'b0;
                        if (mul_state == 2'd0) begin 
                            temp_a <= OPA << 1;
                            temp_b <= OPB;
                            mul_state <= 2'd1; // Trigger Cycle 1
                        end
                        RES <= {(WIDTH*2){1'b0}}; // Clear output while busy
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        mul_err<=1'b1;
                        ERR<=mul_err;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        mul_err<=1'b1;
                        ERR<=mul_err;
                    end
                    else begin
                        mul_err<=1'b1;
                        ERR<=mul_err;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b1011:begin   // Signed addition
                    if(INP_VALID==2'b11) begin
                        RES   <= $signed(OPA) + $signed(OPB);
                        OFLOW <= (OPA[WIDTH-1] == OPB[WIDTH-1]) && ((((OPA + OPB) >> (WIDTH-1)) & 1'b1) != OPA[WIDTH-1]);
                        G<=(OPA>OPB)?1:0;
                        L<=(OPA<OPB)?1:0;
                        E<=(OPA==OPB);
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b1100:begin   //Signed substraction
                    if(INP_VALID==2'b11) begin
                        RES   <= $signed(OPA) - $signed(OPB);
                        OFLOW <= (OPA[WIDTH-1] != OPB[WIDTH-1]) && ((((OPA - OPB) >> (WIDTH-1)) & 1'b1) != OPA[WIDTH-1]);
                        G<=(OPA>OPB)?1:0;
                        L<=(OPA<OPB)?1:0;
                        E<=(OPA==OPB);
                    end
                    else if(INP_VALID==2'b01) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else if(INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                default:begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b0;
                        OFLOW<=1'b0;
                        COUT<=1'b0;
                        G<=1'b0;
                        L<=1'b0;
                        E<=1'b0;
                 end
            endcase
        end
        else begin   //Logical operations
            ERR<=1'b0;
            OFLOW<=1'b0;
            COUT<=1'b0;
            G<=1'b0;
            L<=1'b0;
            E<=1'b0;
            RES={WIDTH*2{1'b0}};
            case(CMD)
                4'b0000:begin          //AND
                    if(INP_VALID==2'b11)
                        RES<=OPA & OPB;
                    else if(INP_VALID==2'b01 || INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G;
                        L<=L;
                        E<=E;
                        RES<=RES;
                    end
                end
                4'b0001:begin           //NAND
                   if(INP_VALID==2'b11)
                        RES<={{WIDTH{1'b0}},~(OPA & OPB)};
                   else if(INP_VALID==2'b01 || INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b0010:begin               //OR
                   if(INP_VALID==2'b11)
                       RES<={{WIDTH{1'b0}},OPA|OPB};
                   else if(INP_VALID==2'b10 || INP_VALID==2'b01) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b0011:begin                  //NOR
                   if(INP_VALID==2'b11)
                       RES<={{WIDTH{1'b0}},~(OPA | OPB)};
                   else if(INP_VALID==2'b10 || INP_VALID==2'b01) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b0100:begin                 //XOR
                   if(INP_VALID==2'b11)
                       RES<={{WIDTH{1'b0}},OPA ^ OPB};
                   else if(INP_VALID==2'b10 || INP_VALID==2'b01) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b0101:begin                   //XNOR
                   if(INP_VALID==2'b11)
                       RES<={{WIDTH{1'b0}},~(OPA ^ OPB)};
                   else if(INP_VALID==2'b10 || INP_VALID==2'b01) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b0110:begin                //NOT_A
                   if(INP_VALID==2'b11 || INP_VALID==2'b01)
                       RES<={{WIDTH{1'b0}},~OPA};
                   else if(INP_VALID==2'b10) begin
                       RES={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b0111:begin                   //NOT_B
                   if(INP_VALID==2'b11 || INP_VALID==2'b10)
                       RES<={{WIDTH{1'b0}},~OPB};
                   else if(INP_VALID==2'b01) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b1000:begin                      //SHR1_A
                   if(INP_VALID==2'b11 || INP_VALID==2'b01)
                       RES<={{WIDTH{1'b0}},(OPA>>1)};
                   else if(INP_VALID==2'b10) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b1001:begin                       //SHL1_A
                   if(INP_VALID==2'b11 || INP_VALID==2'b01)
                       RES<={{WIDTH{1'b0}},(OPA<<1)};
                   else if(INP_VALID==2'b10) begin
                       RES={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b1010:begin                        //SHR1_B
                   if(INP_VALID==2'b11 || INP_VALID==2'b10)
                       RES<={{WIDTH{1'b0}},(OPB>>1)};
                   else if(INP_VALID==2'b10) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b1011:begin                          //SHL1_B
                   if(INP_VALID==2'b11 || INP_VALID==2'b10)
                       RES<={{WIDTH{1'b0}},(OPB<<1)};
                   else if(INP_VALID==2'b10) begin
                       RES<={WIDTH*2{1'b0}};
                       ERR<=1'b1;
                   end
                   else begin
                       ERR<=1'b1;
                       OFLOW<=OFLOW;
                       COUT<=COUT;
                       G<=G;
                       L<=L;
                       E<=E;
                       RES<=RES;
                   end
               end
               4'b1100:begin                                           //ROL_A_B
                    if(INP_VALID==2'b11) begin
                        // Parameterized Error Check: Trigger if any bit > 2 is high
                      if(|OPB[WIDTH-1:4]) begin 
                            ERR<=1'b1;
                        end
                        else begin
                            ERR<=1'b0;
                        end
                        // Parameterized Left Rotate
                        RES <= {{WIDTH{1'b0}}, (OPA << OPB[2:0]) | (OPA >> (WIDTH - OPB[2:0]))};
                    end
                    else if(INP_VALID==2'b01 || INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G; L<=L; E<=E;
                        RES<=RES;
                    end
                end
                
                4'b1101:begin                                           //ROR_A_B
                    if(INP_VALID==2'b11) begin
                        // Parameterized Error Check: Trigger if any bit > 2 is high
                      if(|OPB[WIDTH-1:4]) begin 
                            ERR<=1'b1;
                        end
                        else begin
                            ERR<=1'b0;
                        end
                        // Parameterized Right Rotate
                        RES <= {{WIDTH{1'b0}}, (OPA >> OPB[2:0]) | (OPA << (WIDTH - OPB[2:0]))};
                    end
                    else if(INP_VALID==2'b01 || INP_VALID==2'b10) begin
                        RES<={WIDTH*2{1'b0}};
                        ERR<=1'b1;
                    end
                    else begin
                        ERR<=1'b1;
                        OFLOW<=OFLOW;
                        COUT<=COUT;
                        G<=G; L<=L; E<=E;
                        RES<=RES;
                    end
               end
               default:begin
                   ERR<=ERR;
                   COUT<=COUT;
                   OFLOW<=OFLOW;
                   G<=G;
                   L<=L;
                   E<=E;
                   RES<=RES;
               end
           endcase
         end
         if (mul_state == 2'd2) begin
             RES <= mul;
             ERR <= 1'b0; OFLOW <= 1'b0; COUT <= 1'b0; G <= 1'b0; L <= 1'b0; E <= 1'b0;
         end
       end
       else begin
           ERR<=ERR;
           COUT<=COUT;
           OFLOW<=OFLOW;
           G<=G;
           L<=L;
           E<=E;
           RES<=RES;
       end
   end
endmodule

