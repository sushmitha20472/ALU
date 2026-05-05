
 
module alu2(clk,rst,inp_valid, mode,cmd,ce,opA,opB,cin,err,res,oflow,cout,G,L,E);
parameter DW=8;
parameter C=4;
 
input wire clk,rst,mode,ce,cin;
input wire [1:0]inp_valid;
input wire [DW-1:0]opA,opB;
input wire [C-1:0]cmd;

output reg err,oflow,cout,G,L,E;
output reg [DW*2-1:0]res; 

reg [1:0] pipe_cnt;
reg [DW-1:0] pipe_A, pipe_B;


reg signed [DW-1:0] s_A, s_B;
reg signed [DW:0]   s_res;

always@(posedge clk or posedge rst)
begin
        if(rst)
            begin
                res      <= 0;
                cout     <= 0;
                
                G        <= 0;
                L        <= 0;
                E        <= 0;
                err      <= 0;
                oflow    <= 0;
                pipe_cnt <= 0;
                pipe_A   <= 0;
                pipe_B   <= 0;
            end
        else
           if(ce)
           begin
            
            if(inp_valid == 2'b00 || inp_valid == 2'b01 || inp_valid == 2'b10)
            begin
                res<=0;
                cout<=0;
                G<=0;
                L<=0;
                E<=0;
                err<=0;
                oflow<=0;
                pipe_cnt <= 0;
                pipe_A   <= 0;
                pipe_B   <= 0;
            end
            case(mode)
                1:
                begin
                    case(cmd)
                        0:  
                        begin
                            if(inp_valid==2'b11)
                            begin
                                {cout,res[DW-1:0]} <= opA+opB;
                               
                            end
                            else
                                err<=1;  
                        end
                        
                        1:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                if(opA<opB)
                                begin
                                oflow<=1;
                                end
                                else
                                res <= opA-opB;
                            end
                            else
                                err<=1;
                        end
                        
                        2:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res <= opA+opB+cin; 
                                cout <= res[DW];   
                            end
                            else
                                err <= 1;  
                        end
                        
                        3:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                if(opA<opB)
                                err<=1;
                                else
                                res <= opA-opB-cin;   
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        4:
                        begin
                            if(inp_valid==2'b01 || inp_valid == 2'b11)
                            begin
                                res[DW-1:0] <= opA+1;   
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        5:
                        begin
                            if(inp_valid==2'b01 || inp_valid == 2'b11)
                            begin
                                res[DW-1:0] <= opA-1;   
                            end
                            else
                                err <= 1;                                             
                        end                        
                            
                        6:
                        begin
                            if(inp_valid==2'b10 || inp_valid == 2'b11)
                            begin
                                res[DW-1:0] <= opB+1;   
                            end
                            else
                                err <= 1;                                             
                        end                        
                        
                        7:
                        begin
                            if(inp_valid==2'b10 || inp_valid == 2'b11)
                            begin
                                res[DW-1:0] <= opB-1;   
                            end
                            else
                                err <= 1;                                             
                        end                        
                        
                        8:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                if(opA<opB)begin G<=1;L<=0;E<=0;end
                                else if(opA>opB)begin G<=0;L<=1;E<=0;end
                                else begin G<=0;L<=0;E<=1;end
                            end
                            else
                                err <= 1;                                         
                        end
                        
                        9: begin
                        if(inp_valid == 2'b11) begin
                            if(pipe_cnt == 0) begin
                                pipe_A      <= opA + 1;
                                pipe_B      <= opB + 1;
                                pipe_cnt    <= 1;
                            end
                            else if(pipe_cnt == 1) begin
                                pipe_cnt <= 2;
                            end
                            else if(pipe_cnt == 2) begin
                                res         <= pipe_A * pipe_B;
                                pipe_cnt    <= 0;
                            end
                        end
                        else
                            err <= 1;
                    end

                    
                    10: begin
                        if(inp_valid == 2'b11) begin
                            if(pipe_cnt == 0) begin
                                pipe_A      <= opA << 1;
                                pipe_B      <= opB;
                                pipe_cnt    <= 1;
                            end
                            else if(pipe_cnt == 1) begin
                                pipe_cnt <= 2;
                            end
                            else if(pipe_cnt == 2) begin
                                res         <= pipe_A*pipe_B;
                                pipe_cnt    <= 0;
                            end
                        end
                        else
                            err <= 1;
                    end

                    4'd11: begin
                        if(inp_valid == 2'b11) begin
                            
                            s_A   = $signed(opA);
                            s_B   = $signed(opB);
                            s_res = s_A + s_B;
                            
                            res   <= {{DW-1{s_res[DW]}}, s_res};

                            oflow <= (~opA[DW-1] & ~opB[DW-1] & s_res[DW-1]) |
                                     ( opA[DW-1] &  opB[DW-1] & ~s_res[DW-1]);

                            if(s_A > s_B)      begin G<=1; E<=0; L<=0; end
                            else if(s_A < s_B) begin G<=0; E<=0; L<=1; end
                            else               begin G<=0; E<=1; L<=0; end
                        end
                        else
                            err <= 1;
                    end

                   
                    4'd12: begin
                        if(inp_valid == 2'b11) begin 
                            s_A   = $signed(opA);
                            s_B   = $signed(opB);
                            s_res = s_A - s_B;
                           
                            res   <= {{DW-1{s_res[DW]}}, s_res};
                            
                            oflow <= (~opA[DW-1] &  opB[DW-1] & s_res[DW-1]) |
                                     ( opA[DW-1] & ~opB[DW-1] & ~s_res[DW-1]);
                        
                            if(s_A > s_B)      begin G<=1; E<=0; L<=0; end
                            else if(s_A < s_B) begin G<=0; E<=0; L<=1; end
                            else               begin G<=0; E<=1; L<=0; end
                        end
                        else
                            err <= 1;
                    end

                    default: begin
                        res   <= 0;
                        cout  <= 0;
                        G     <= 0;
                        L     <= 0;
                        E     <= 0;
                        err   <= 0;
                        oflow <= 0;
                    end
                    
                endcase
            end
                
            
                0:
                begin
                    case(cmd)
                        0:  
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= opA&opB;   
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        1:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= ~(opA&opB);   
                            end
                            else
                                err <= 1;                                             
                        end  
                        
                        2:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= opA|opB;   
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        3:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= ~(opA|opB);   
                            end
                            else
                                err <= 1;                                             
                        end   
                        
                        4:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= opA^opB;   
                            end
                            else
                                err <= 1;                                             
                        end                                             
                              
                        5:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= ~(opA^opB);   
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        6:
                        begin
                            if(inp_valid==2'b01 || inp_valid == 2'b11)
                            begin
                                res[7:0] <= ~opA;   
                            end
                            else
                                err <= 1;                                             
                        end   
                        
                        7:
                        begin
                            if(inp_valid==2'b10 || inp_valid == 2'b11)
                            begin
                                res[7:0] <= ~opB;   
                            end
                            else
                                err <= 1;                                             
                        end 
                        
                        8:
                        begin
                            if(inp_valid==2'b11||inp_valid==2'b01)
                            begin
                                res[7:0] <= opA>>1;   
                            end
                            else
                                err <= 1;                                             
                        end   
                        
                        9:
                        begin
                            if(inp_valid==2'b01 || inp_valid == 2'b11)
                            begin
                                res[7:0] <= opA<<1;   
                            end
                            else
                                err <= 1;                                             
                        end   
                        
                        10:
                        begin
                            if(inp_valid==2'b10 || inp_valid == 2'b11)
                            begin
                                res[7:0] <= opB>>1;   
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        11:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                res[7:0] <= opB<<1;   
                            end
                            else
                                err <= 1;                                             
                        end 
                        
                        12:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                if(opB>4'b1111)
                                err<=1;
                                else
                                res[7:0] <= (opA>>DW-opB[2:0])|(opA<<opB[2:0]); 
                                 
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        13:
                        begin
                            if(inp_valid==2'b11)
                            begin
                                if(opB>4'b1111)
                                err<=1;
                                else
                                res[7:0] <= (opA[2:0]<<DW-opB)|(opA>>opA[2:0]);  
                            end
                            else
                                err <= 1;                                             
                        end
                        
                        default:
                        begin
                            res<=0;
                            cout<=0;
                            G<=0;
                            L<=0;
                            E<=0;
                            err<=0;
                            oflow<=0;                                                                                                                                                                                                                                                                                  
                        end
                    endcase
                end
            endcase
        end
   end

endmodule

