module Contador(
	input clk,	//Señal de reloj 50MHz
	input rst,	//Pulso de reset
	input hold, //Pulso de reten
	input varCont, //Pulso de conteo
	input [7:0]nCont,//Conteo deseado
	output [7:0]an,seg,	//Conf para display
	output buzzer	//Señal de alarma
  );
  
	//Declaración de registros.
	reg [7:0]data[0:9]; //memoria
	reg [7:0]anodos, segmentos; //Conf display
	reg [7:0]cnt;
	reg [31:0]cont_chEdo;
	reg [7:0]decenas,unidades; //Digitos
	reg ch_Edo; //Cambio de display
	reg beep;	//Señal de sonido
	reg [31:0] cnt_rebote;
	reg edo_rebote;
	//Inicialización de variables.
	initial begin
		anodos = 0;
		segmentos = 0;
		cnt = 0;
		ch_Edo = 0;
		beep = 1;
		decenas = 0;
		unidades = 0;
		cont_chEdo = 0;
		edo_rebote = 0;
		cnt_rebote = 0;
	end
	//Memoria para conf display
	initial begin
				  //pgfedcba
		data[0] = 8'b11000000; //0
		data[1] = 8'b11111001; //1
		data[2] = 8'b10100100; //2
		data[3] = 8'b10110000; //3.
		data[4] = 8'b10011001; //4
		data[5] = 8'b10010010; //5
		data[6] = 8'b10000011; //6.
		data[7] = 8'b11111000; //7
		data[8] = 8'b10000000; //8
		data[9] = 8'b10011000; //9
	end
	//Bloque de instrucciones para lectura de datos
	always@(posedge clk)begin
		if(rst == 0) cnt = 0;
		else begin
			if(hold == 0) cnt = cnt;	
			else begin
				case(edo_rebote)
					0: begin
						if(varCont == 0) edo_rebote <= 1; 
						cnt_rebote <= 0;
					end
					1: begin  //Tiempo para que se quite el rebote
						if(cnt_rebote == 5_000_000)begin
							edo_rebote <= 0;
							cnt = cnt + 1;
							edo_rebote <= 0;
						end
						else cnt_rebote <= cnt_rebote + 1; 
						
						if(cnt <= nCont) beep = 1;
						else beep = 0;	
					end
				endcase
			end
		end
		decenas = cnt/10;
		unidades = cnt - (decenas * 10);
	end
  
  //Bloque de instrucciones para visualizacion de datos
	always@(posedge clk) begin
		if(cont_chEdo == 50_00)begin
			ch_Edo <= ~ch_Edo;
			cont_chEdo <= 0;
		end
		else cont_chEdo <= cont_chEdo + 1;
		
		case(ch_Edo)
			0: begin
				anodos <= 8'b11111110; 
				segmentos <= data[unidades];
			end
			1: begin
				anodos <= 8'b11111101; 
				segmentos <= data[decenas];
			end
		endcase
	end
	assign an = anodos;
	assign seg = segmentos;
	assign buzzer = beep;
endmodule
