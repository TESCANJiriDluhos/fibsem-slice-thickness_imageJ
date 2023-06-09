// "phase correlation
setBatchMode(true);
size=128;
path = "\\\\nas_rdapp\\Vyvoj_aplikaci\\nas.vaclav.ondracka\\Tomo data\\121-0297\\ultimate ruler measurement rocking\\Dataset 1\\Mid-Angle BSE+In-Beam f-BSE\\";
ini = "0010";
name1 = "slice-"+ini+".png";

start = "slice-";
ending = ".png";
num = 1571;
end_track=542;
start_track = 3410;
start_track_y = 406;
size_peakfitG = 31;
lines=9;

manual_adjust = newArray(-5,0,0,20,20,0,30,20,25,15,20,30,30,30,30);

point = newArray(128, 480, 290, 478, 612, 474, 1188, 462, 1764, 448, 2332, 428, 2910, 414, 3730, 394, 3898, 382);

file_x_name = path + "results_x"+ini + ".txt";
file_y_name = path + "results_y"+ini + ".txt";

file_x = File.open(file_x_name);
print(file_x,"Header for x results");
File.close(file_x);

file_y = File.open(file_y_name);
print(file_y,"Header for y results");
File.close(file_y);

sum_x = newArray(lines);
sum_y = newArray(lines);
peak_max = newArray(lines);
Gres_x = newArray(lines);
Gres_y = newArray(lines);
position_x = newArray(2*lines);
position_y = newArray(2*lines);
retrace = newArray(lines);

Gx=newArray(size_peakfitG);
Gy=newArray(size_peakfitG);
Gvalue=newArray(size_peakfitG);

newImage("Untitled", "8-bit black", size, size, 1);
selectWindow("Untitled");
run("FFT Options...", "complex do");

//opening the first relative image for correlation
print("Starting slicing count relative to image" + name1);
open(path + name1);
rename("ref");
name1="ref";
run("32-bit");
//run("Invert");

//cmputing FFTs of the first image
for(l=0; l<lines; l++){
	selectWindow(name1);
	makeRectangle(point[0+l*2], point[1+l*2], size, size);

	run("FFT Options...", "complex raw do");
	selectWindow("PS of "+ name1);
	close();
	selectWindow("Complex of " + name1);
	run("Stack to Images");
	selectWindow("Real");
	rename("a" + l);
	selectWindow("Imaginary");
	rename("b" + l);

	sum_x[l]=0;//fill em with 0s
	sum_y[l]=0;//fill em with 0s
	position_x[l]=0;
	position_x[l+lines]=0;
	position_y[l]=0;
	position_y[l+lines]=0;
	retrace[l] = 0;
}

//for each image
for(k=1+ini; k<num+1+ini; k=k+1){
	sk="";
	if(k<10)
		sk="000"+k;
	else if(k<100)
		sk="00"+k;
	else if(k<1000)
		sk="0"+k;
	else
		sk=""+k;

//obrzlička na retracing
/*	if(k>1300){
		start_track = 3570;
	}*/

	//opening image for correlation
	name2 = start + sk + ending;
	print(name2);
	open(path + name2);
	rename("sub");
	name2="sub";
	run("32-bit");
	//run("Invert");

	stringx_x = "";
	stringx_s = "";
	stringx_R2 = "";

	stringy_y = "";
	stringy_s = "";
	stringy_R2 = "";

	peak_sum = 0;

	//for each line 
	for(l=0; l<lines; l++){
		//computing FFTs
		selectWindow(name2);
		makeRectangle( point[0+l*2]+position_x[l+lines], point[1+l*2]+position_y[l+lines], size, size);
		run("FFT Options...", "complex raw do");
		selectWindow("PS of "+ name2);
		close();
		selectWindow("Complex of " + name2);
		run("Stack to Images");
		selectWindow("Real");
		rename("c");
		selectWindow("Imaginary");
		rename("d");

		//do i need to make a new reference because of retrace? 
		if(retrace[l] == 1){
			selectWindow("a"+l);
			close();
			selectWindow("b"+l);
			close();
			selectWindow("c");
			rename("a"+l);
			selectWindow("d");
			rename("b"+l);

			stringx_x = stringx_x + ", ";
			stringx_s = stringx_s + ", ";
			stringx_R2 = stringx_R2 + ", "; 

			stringy_y = stringy_y + ", ";
			stringy_s = stringy_s + ", ";
			stringy_R2 = stringy_R2 + ", ";
			
			retrace[l] = 0;
			print("retracing");
			//drawing in the window
			selectWindow(name2);
			run("Line Width...", "line=5");
			makeRectangle( point[0+l*2]+position_x[l+lines], point[1+l*2]+position_y[l+lines], size, size);			
			setForegroundColor(0, 0, 0);
			run("Draw", "slice");
			save(path + "\\retracing\\" + k + ".png");
			//waitForUser();
			continue;
		}

		//computing cross correlation
		imageCalculator("Multiply create 32-bit", "a"+l,"c");
		selectWindow("Result of a"+l);
		rename("ac");
		imageCalculator("Multiply create 32-bit", "a"+l,"d");
		selectWindow("Result of a"+l);
		rename("ad");
		imageCalculator("Multiply create 32-bit", "b"+l,"c");
		selectWindow("Result of b"+l);
		rename("bc");
		imageCalculator("Multiply create 32-bit", "b"+l,"d");
		selectWindow("Result of b"+l);
		rename("bd");

		imageCalculator("Add create 32-bit", "ac","bd");
		selectWindow("Result of ac");
		rename("phase_r");
		imageCalculator("Subtract create 32-bit", "bc","ad");
		selectWindow("Result of bc");
		rename("phase_i");

		//prepare new windows as old reference
		selectWindow("a"+l);
		close();
		selectWindow("b"+l);
		close();
		selectWindow("c");
		rename("a"+l);
		selectWindow("d");
		rename("b"+l);

		selectWindow("ac");
		close();
		selectWindow("bd");
		close();
		selectWindow("bc");
		close();
		selectWindow("ad");
		close();

		selectWindow("phase_r");
		for (i=0; i<size; i++){
			for (j=0; j<size; j++){
      		setPixel(i,j, getPixel(i,j)*Math.pow(-1, i+j));
			}
		}
		selectWindow("phase_i");
		for (i=0; i<size; i++){
			for (j=0; j<size; j++){
     		 setPixel(i,j, getPixel(i,j)*Math.pow(-1, i+j));
			}
		}

		run("Images to Stack", "name=Complex title=[phase] use");

		selectWindow("Complex");
		setSlice(1);
		run("Copy");
		selectWindow("Complex of Untitled");
		setSlice(1);
		run("Paste");
		selectWindow("Complex");
		setSlice(2);
		run("Copy");
		selectWindow("Complex of Untitled");
		setSlice(2);
		run("Paste");
		run("Inverse FFT");
		rename("cor"+l + name2);
		setSlice(2);
		run("Delete Slice");


		//peak fitting
		max=0;
		for (x = 0; x < size; x++) {
				for (y = 0; y < size; y++) {
					if(getPixel(x,y)>max){
						max = getPixel(x,y);
						peak_x = x;
						peak_y = y;
					}
				}
		}

		peak_max[l] = max;
		peak_sum = peak_sum + max;

		for (i = 0; i < size_peakfitG; i++) {
			Gx[i]=peak_x+(i-(size_peakfitG-1)/2);
			Gy[i]=peak_y+(i-(size_peakfitG-1)/2);
		}

		for (i = 0; i < size_peakfitG; i++) {
			Gvalue[i]=getPixel(Gx[i],peak_y);
		}
		Fit.doFit("Gaussian", Gx, Gvalue);
		Gres_x[l]=-Fit.p("2")+size/2+(position_x[l+lines]-position_x[l]); //peak position - center position + (current ROI position - previus ROI position)

		stringx_x = stringx_x + Gres_x[l] + ", ";
		stringx_s = stringx_s + Fit.p("3") + ", ";
		stringx_R2 = stringx_R2 + Fit.rSquared + ", "; 


		for (i = 0; i < size_peakfitG; i++) {
			Gvalue[i]=getPixel(peak_x,Gy[i]);
		}
		
		Fit.doFit("Gaussian", Gy, Gvalue);
		Gres_y[l]=-Fit.p("2")+size/2+(position_y[l+lines]-position_y[l]); //peak position - center position + (current ROI position - previus ROI position)

		stringy_y = stringy_y + Gres_y[l] + ", ";
		stringy_s = stringy_s + Fit.p("3") + ", ";
		stringy_R2 = stringy_R2 + Fit.rSquared + ", "; 

		sum_x[l] = sum_x[l] + Gres_x[l]; //how much has the area shifted since the beginning, used for initial window selection
		sum_y[l] = sum_y[l] + Gres_y[l];

		position_x[l] = position_x[l+lines]; //assign current position to the previous one
		position_y[l] = position_y[l+lines]; //assign current position to the previous one

		position_x[l+lines] = floor(sum_x[l]);//update the next position
		position_y[l+lines] = floor(sum_y[l]);

		if (l>1){
			//print(point[0+l*2]+position_x[l+lines]);
			if (point[0+l*2]+position_x[l+lines]< (end_track+(sum_x[0]+sum_x[1])/2)) {
				retrace[l] = 1;
				sum_x[l]=0;
				sum_y[l]=0;
				Gres_x[l] = 0;
				Gres_y[l] = 0;
				position_x[l+lines] = 0;
				position_x[l] = 0;
				position_y[l]=0;
				position_y[l+lines]=0;
				point[0+l*2] = start_track + (sum_x[0]+sum_x[1])/2 + manual_adjust[0];
				point[1+l*2] = start_track_y + (sum_y[0]+sum_y[1])/2;
				manual_adjust = Array.slice(manual_adjust,1);
				print("ordered retracing");
			}
		}

		selectWindow("Complex");
		close();
		selectWindow("cor"+l + name2);
		close();
	}//for every line

	selectWindow(name2);
	close();


string_peak = "";
for (l = 0; l < lines; l++) {
	peak_max[l] = peak_max[l] / peak_sum;
	string_peak = string_peak + peak_max[l] + ", ";

}//for every image

File.append(k + ", " + stringx_x + ", , ," + stringx_s + ", , ," + stringx_R2 + ", , ," + string_peak ,file_x_name);
File.append(k + ", " + stringy_y + ", , ," + stringy_s + ", , ," + stringy_R2 + ", , ," + string_peak ,file_y_name);
//File.append("Header for y results",file_y_name);
//Array.print(Gres_y);


}

selectWindow("Complex of Untitled");
close();
selectWindow("Untitled");
close();

