module voice_play_control(
	I_clk,
	I_rst_n,
	I_en,
	select,
	init_en,
	init_rst_n,
	run_en,
	run_rst_n,
	stop_en,
	stop_rst_n,
	left_en,
	left_rst_n,
	right_en,
	right_rst_n,
	init_done,
	run_done,
	stop_done,
	left_done,
	right_done);

	//---Ports declearation: generated by Robei---
	input I_clk;
	input I_rst_n;
	input I_en;
	input [1:0] select;
	output init_en;
	output init_rst_n;
	output run_en;
	output run_rst_n;
	output stop_en;
	output stop_rst_n;
	output left_en;
	output left_rst_n;
	output right_en;
	output right_rst_n;
	input init_done;
	input run_done;
	input stop_done;
	input left_done;
	input right_done;

	wire I_clk;
	wire I_rst_n;
	wire I_en;
	wire [1:0] select;
	reg init_en;
	reg init_rst_n;
	reg run_en;
	reg run_rst_n;
	reg stop_en;
	reg stop_rst_n;
	reg left_en;
	reg left_rst_n;
	reg right_en;
	reg right_rst_n;
	wire init_done;
	wire run_done;
	wire stop_done;
	wire left_done;
	wire right_done;

	//----Code starts here: integrated by Robei-----
	reg [2:0] state;//状态机进行控制
	reg [2:0] jump_state;//状态跳转
	reg [1:0] select_tmp;//状态暂存
	reg f;
	//函数
	function Reset;
		input	[1:0]select;
		case(select)
		2'd0:begin	run_en=0;
			run_rst_n=0;end
		2'd1:begin	stop_en=0;
			stop_rst_n=0; end
		2'd2:begin	left_en=0;
			left_rst_n=0; end
		2'd3:begin	right_en=0;
			right_rst_n=0; end
		default:;
		endcase
	endfunction
	//函数
	function Enable;
		input	[1:0]select;
		case(select)
		2'd0:begin	run_en=1;
			run_rst_n=1;end
		2'd1:begin	stop_en=1;
			stop_rst_n=1; end
		2'd2:begin	left_en=1;
			left_rst_n=1; end
		2'd3:begin	right_en=1;
			right_rst_n=1; end
		default:;
		endcase
	endfunction
	
	function Finished;
		input	[1:0]select;
		case(select)
		2'd0:begin	if(run_done)begin
			run_en=0;
			state=3'd6;end
			else
			state=state;end
		2'd1:begin	if(stop_done)begin
			stop_en=0;
			state=3'd6;end
			else
			state=state; end
		2'd2:begin	if(left_done)begin
			left_en=0;
			state=3'd6;end
			else
			state=state;end
		2'd3:begin	if(right_done)begin
			right_en=0;
			state=3'd6;end
			else
			state=state; end
		default:;
		endcase
	endfunction
	
	always@(negedge I_rst_n,posedge I_clk)
	begin
		if(!I_rst_n)//复位
		begin
			//输出赋初值
			init_en<=0;//进行语音配置初始化
			init_rst_n<=1;
			run_en<=0;
			run_rst_n<=1;
			stop_en<=0;
			stop_rst_n<=1;
			left_en<=0;
			left_rst_n<=1;
			right_en<=0;
			right_rst_n<=1;
			state<=3'd0;
		end
		else
	if(I_en)
	begin
		case(state)
		3'd0:begin
			init_en<=0;
			init_rst_n<=0;//初始化复位
			state<=state+3'd1;
				end
		3'd1:begin
			init_en<=1;//开始运行
			init_rst_n<=1;
	//初始化完成后进入下一个阶段
			if(init_done)
			state<=state+3'd1;
			else
			state<=state;
				end
		3'd2:begin//结束初始化
			init_en<=0;
			init_rst_n<=1;
			state<=state+3'd1;
				end
		3'd3:begin//读取状态
			select_tmp<=select;
			state<=state+3'd1;
				end
		3'd4:begin//复位
			f=Reset(select_tmp);
			state<=state+3'd1;
				end
		3'd5:begin//使能
			f=Enable(select_tmp);
			f=Finished(select_tmp);
				end
		3'd6:begin//等待状态改变
				if(select!=select_tmp)
					state<=3'd3;
				else
					state<=state;
				end
		endcase
	end
	
	end
	
	
	
endmodule    //voice_play_control
