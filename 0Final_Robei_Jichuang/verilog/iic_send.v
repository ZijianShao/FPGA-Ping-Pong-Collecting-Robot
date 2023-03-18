module iic_send(
	I_clk,
	I_rst_n,
	I_write_data,
	I_iic_send_en,
	O_scl,
	O_done_flag,
	O_sda_mode,
	IO_sda);

	//---Ports declearation: generated by Robei---
	input I_clk;
	input I_rst_n;
	input [7:0] I_write_data;
	input I_iic_send_en;
	output O_scl;
	output O_done_flag;
	output O_sda_mode;
	inout IO_sda;

	wire I_clk;
	wire I_rst_n;
	wire [7:0] I_write_data;
	wire I_iic_send_en;
	wire O_scl;
	reg O_done_flag;
	wire O_sda_mode;
	wire IO_sda;

	//----Code starts here: integrated by Robei-----
	parameter   C_DIV_SELECT        =   16'd5000 ; // ��Ƶϵ��ѡ��
	
	parameter   C_DIV_SELECT0       =   (C_DIV_SELECT >> 2)  -  1           , // ��������IIC����SCL�͵�ƽ���м�ı�־λ
	            C_DIV_SELECT1       =   (C_DIV_SELECT >> 1)  -  1           ,
	            C_DIV_SELECT2       =   (C_DIV_SELECT0 + C_DIV_SELECT1) + 1 , // ��������IIC����SCL�ߵ�ƽ���м�ı�־λ
	            C_DIV_SELECT3       =   (C_DIV_SELECT >> 1)  +  1           ; // ��������IIC����SCL�½��ر�־λ
	 
	
	reg     [15:0]   R_scl_cnt       ; // ��������IIC����SCLʱ���ߵļ�����   
	reg             R_scl_en        ; // IIC����SCLʱ����ʹ���ź�
	reg     [3:0]   R_state         ; 
	reg             R_sda_mode      ; // ����SDAģʽ��1λ�����0Ϊ����
	reg             R_sda_reg       ; // SDA�Ĵ���
	reg     [7:0]   R_load_data     ; // ����/���չ����м��ص����ݣ������豸������ַ���ֵ�ַ�����ݵ�
	reg     [3:0]   R_bit_cnt       ; // �����ֽ�״̬��bit��������
	reg             R_ack_flag      ; // Ӧ���־
	reg     [3:0]   R_jump_state    ; // ��ת״̬������һ���ֽڳɹ���Ӧ���Ժ�ͨ�����������ת��������һ�����ݵ�״̬
	
	wire            W_scl_low_mid   ; // SCL�ĵ͵�ƽ�м��־λ
	wire            W_scl_high_mid  ; // SCL�ĸߵ�ƽ�м��־λ
	wire            W_scl_neg        ; // SCL���½��ر�־λ
	wire 			[6:0] I_dev_addr;
	assign I_dev_addr=7'h30;//�̶���ַ
	assign O_sda_mode=R_sda_mode;
	assign IO_sda  =  (R_sda_mode == 1'b1) ? R_sda_reg : 1'bz ;
	
	always @(posedge I_clk or negedge I_rst_n)
	begin
	    if(!I_rst_n)
	        R_scl_cnt   <=  16'd0 ; 
	    else if(R_scl_en)   
	        begin
	            if(R_scl_cnt == C_DIV_SELECT - 1'b1)
	                R_scl_cnt <= 16'd0 ;
	            else
	                R_scl_cnt <= R_scl_cnt + 1'b1 ;     
	        end
	    else
	        R_scl_cnt     <= 16'd0 ;
	end
	
	assign O_scl           = (R_scl_cnt <= C_DIV_SELECT1) ? 1'b1 : 1'b0 ; // ��������ʱ���ź�O_scl
	assign W_scl_low_mid  = (R_scl_cnt == C_DIV_SELECT2) ? 1'b1 : 1'b0 ; // ����scl�͵�ƽ���м��־λ
	assign W_scl_high_mid = (R_scl_cnt == C_DIV_SELECT0) ? 1'b1 : 1'b0 ; // ����scl�ߵ�ƽ���м��־λ
	assign W_scl_neg       = (R_scl_cnt == C_DIV_SELECT3) ? 1'b1 : 1'b0 ; // ����scl�½��ر�־λ
	
	always @(posedge I_clk or negedge I_rst_n)
	begin
	    if(!I_rst_n)
	        begin
	            R_state         <=  4'd0 ;
	            R_sda_mode      <=  1'b1 ;
	            R_sda_reg       <=  1'b1 ;
	            R_bit_cnt       <=  4'd0 ;
	            O_done_flag     <=  1'b0 ;
	            R_jump_state    <=  4'd0 ;
	            R_ack_flag        <=    1'b0 ;
	        end
	    else if(I_iic_send_en) // ��IIC�豸��������
	        begin
	            case(R_state)
	                4'd0   : // ����״̬����SCL��SDA��Ϊ��
	                    begin
	                        R_sda_mode      <=  1'b1 ; // ����SDAΪ���
	                        R_sda_reg       <=  1'b1 ; // ����SDAΪ�ߵ�ƽ
	                        R_scl_en        <=  1'b0 ; // �ر�SCLʱ����
	                        R_state         <=  4'd1 ; // ��һ��״̬�Ǽ����豸������ַ״̬
	                        R_bit_cnt       <=  4'd0 ; // �����ֽ�״̬��bit������������
	                        O_done_flag     <=  1'b0 ;
	                        R_jump_state    <=  4'd0 ;
	                    end                               
	                4'd1   :  // ����IIC�豸������ַ              
	                    begin                             
	                        R_load_data     <=  {I_dev_addr, 1'b0}  ;
	                        R_state         <=  4'd4                ;
	                        R_jump_state    <=  4'd3                ;
	                    end                                     
	                4'd2   :;                                    
	                4'd3   :    // ����Ҫ���͵�����                    
	                    begin                                   
	                        R_load_data     <=  I_write_data        ; 
	                        R_state         <=  4'd5                ;
	                        R_jump_state    <=  4'd8                ;
	                    end                                                         
	                4'd4   :    // ������ʼ�ź�                   
	                    begin                                   
	                        R_scl_en    <=  1'b1                ; // ��SCLʱ����
	                        R_sda_mode  <=  1'b1                ; // ����SDAΪ���
	                        if(W_scl_high_mid)                  
	                            begin                           
	                                R_sda_reg   <=  1'b0        ; // ��SCL�ߵ�ƽ�м��SDA�ź�����,������ʼ�ź�
	                                R_state     <=  4'd5        ; 
	                            end
	                        else
	                            R_state <=  4'd4                ; // ���SCL�ߵ�ƽ�м��־û���־�һֱ�����״̬����                          
	                    end
	                4'd5   :    // ����1���ֽڣ��Ӹ�λ��ʼ��
	                    begin
	                        R_scl_en    <=  1'b1                ; // ��SCLʱ����
	                        R_sda_mode  <=  1'b1                ; // ����SDAΪ���
	                        if(W_scl_low_mid)
	                            begin
	                                if(R_bit_cnt == 4'd8)
	                                    begin
	                                        R_bit_cnt   <=  4'd0            ;
	                                        R_state     <=  4'd6            ; // �ֽڷ����Ժ����Ӧ��״̬
	                                    end
	                                else
	                                    begin                                 
	                                        R_sda_reg   <=  R_load_data[7-R_bit_cnt] ; // �ȷ��͸�λ
	                                        R_bit_cnt   <=  R_bit_cnt + 1'b1         ; 
	                                    end
	                            end
	                        else
	                            R_state <=  4'd5 ; // �ֽ�û����ʱ�����״̬һֱ�ȴ� 
	                    end 
	                4'd6   :    // ����Ӧ��״̬��Ӧ��λ
	                    begin
	                        R_scl_en    <=  1'b1  ; // ��SCLʱ����
	                        R_sda_mode  <=  1'b0  ; // ����SDAΪ����
	                        if(W_scl_high_mid)
	                            begin
	                                R_ack_flag  <=  IO_sda  ; 
	                                R_state     <=  4'd7    ; 
	                            end                            
	                        else
	                            R_state <=  4'd6  ;     
	                    end
	                4'd7  :    // У��Ӧ��λ
	                    begin
	                        R_scl_en    <=  1'b1  ; // ��SCLʱ����                        
	                        if(R_ack_flag == 1'b0)    // У��ͨ��
	                            begin
	                                if(W_scl_neg == 1'b1) 
	                                    begin
	                                        R_state <=  R_jump_state ;
	                                        R_sda_mode  <=  1'b1 ; // ����SDA��ģʽΪ���
	                                        R_sda_reg   <=  1'b0 ; // ��ȡ��Ӧ���ź��Ժ�Ҫ��SDA�ź����ó���������ͣ���Ϊ������״
	                                                               // ̬������ֹͣ״̬�Ļ�����ҪSDA�źŵ������أ�����������ǰ������
	                                    end
	                                else
	                                    R_state <= 4'd7    ;
	                            end
	                        else
	                            R_state <=  4'd0 ;      
	                    end
	                4'd8   : // ����ֹͣ�ź�
	                    begin
	                        R_scl_en    <=  1'b1        ; // ��SCLʱ����
	                        R_sda_mode  <=  1'b1        ; // ����SDAΪ���
	                        if(W_scl_high_mid)
	                            begin
	                                R_sda_reg   <=  1'b1 ;
	                                R_state     <=  4'd9 ;
	                            end
	                    end
	                4'd9    :   // IICд��������
	                    begin
	                        R_scl_en    <=  1'b0 ; // �ر�SCLʱ����
	                        R_sda_mode  <=  1'b1 ; // ����SDAΪ���
	                        R_sda_reg   <=  1'b1 ; // ����SDA���ֿ���״̬���
	                        O_done_flag <=  1'b1 ;
	                        R_state     <=  4'd0 ; 
	                        R_ack_flag  <=  1'b0 ;
	                    end  
	                default    : R_state     <=  4'd0 ; 
	            endcase
	        end 
	    else
	        begin
	            R_state         <=  4'd0 ;
	            R_sda_mode      <=  1'b1 ;
	            R_sda_reg       <=  1'b1 ;
	            R_bit_cnt       <=  4'd0 ;
	            O_done_flag     <=  1'b0 ;
	            R_jump_state    <=  4'd0 ;
	            R_ack_flag      <=  1'b0 ;
	        end
	end
	
	
	
endmodule    //iic_send
