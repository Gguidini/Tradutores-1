int f(int a, float b){
	outInt a;
	outFloat b;
	float x;
	x = b + a;
	outFloat x;
}

int main(){
	int x;
	float y;
	y = 5.4;
	x = 10;
	f(x, f(y, y));
	return 1;
}
