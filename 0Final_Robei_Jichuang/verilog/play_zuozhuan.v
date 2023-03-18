module play_zuozhuan(
	I_clk,
	I_en,
	I_rst_n,
	I_done_flag,
	O_data,
	O_iic_send_en,
	O_Byte_done);

	//---Ports declearation: generated by Robei---
	input I_clk;
	input I_en;
	input I_rst_n;
	input I_done_flag;
	output [7:0] O_data;
	output O_iic_send_en;
	output O_Byte_done;

	wire I_clk;
	wire I_en;
	wire I_rst_n;
	wire I_done_flag;
	reg [7:0] O_data;
	reg O_iic_send_en;
	reg O_Byte_done;

	//----Code starts here: integrated by Robei-----
	reg [3:0]state;
	always@(posedge I_clk,negedge I_rst_n)//状态机负责切换发送的数据
	begin
	if(!I_rst_n)
		begin
			state<=4'd0;
			O_data<=8'hfd;
			O_iic_send_en<=1;
			O_Byte_done<=0;
		end
	else
	if(I_en)
		begin
		case(state)
		4'd0:begin
				O_data<=8'hfd;//第1个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd1:begin
				O_data<=8'h0;//第2个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd2:begin
				O_data<=8'h0c;//第3个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd3:begin
				O_data<=8'h01;//第4个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd4:begin
				O_data<=8'h0;//第5个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd5:begin
				O_data<=8'h7a;//第6个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd6:begin
				O_data<=8'h75;//第7个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd7:begin
				O_data<=8'h6f;//第8个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd8:begin
				O_data<=8'h32;//第9个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd9:begin
				O_data<=8'h7a;//第10个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd10:begin
				O_data<=8'h68;//第11个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd11:begin
				O_data<=8'h75;//第12个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd12:begin
				O_data<=8'h61;//第13个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd13:begin
				O_data<=8'h6e;//第14个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd14:begin
				O_data<=8'h32;//第14个要发送的数据
				if(I_done_flag)
						state<=state+1;
				else
						state<=state;
				end
		4'd15:begin
				if(I_done_flag)//发送结束
				//进行复位
				begin
						O_iic_send_en<=0;
						O_Byte_done<=1;
				end
				else
						state<=state;
		end		
		default:;
		endcase
		end
	end
	
	
	
	
	
	
endmodule    //play_zuozhuan

