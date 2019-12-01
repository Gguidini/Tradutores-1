int f(int a, int b[], float c[]){
	return a + b[1];
}

int main(){
	int x[5];
	float y[1];
	x[3] = f(1, x, y);
}
